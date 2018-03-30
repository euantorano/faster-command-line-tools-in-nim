#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <inttypes.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <pthread.h>

enum {
	NWorkers = 14,
	NBucket = 2048,
};

typedef struct Bucket Bucket;
typedef struct Worker Worker;

struct Bucket {
	char **key;
	int *count;
	size_t size;
};

struct Worker {
	pthread_t thread;
	size_t beg, end;
	Bucket hash[NBucket];
};

Worker w[NWorkers];
char *data;

void
die(char *msg)
{
	fputs(msg, stderr);
	exit(1);
}

int
addcount(Bucket *b, char *key, int count)
{
	size_t n;

	for (n=0; n<b->size; n++)
		if (strcmp(key, b->key[n]) == 0)
			return b->count[n] += count;
	b->size++;
	b->key = realloc(b->key, b->size);
	b->count = realloc(b->count, b->size);
	b->key[n] = key;
	return b->count[n] = count;
}

void *
worker(void *p)
{
	char *key, *cur, *endp;
	size_t beg, end;
	int count;
	uint32_t h;
	Bucket *hash;
	Worker *pw;

	pw = p;
	hash = pw->hash;
	beg = pw->beg;
	end = pw->end;

	cur = &data[beg];
	endp = &data[end];

	do {
		while (*cur != '\t')
			cur++;
		key = ++cur;
		h = 0;
		while (*cur != '\t') {
			h = h*33 + *cur;
			cur++;
		}
		*cur++ = 0;
		count = 0;
		while (*cur != '\t') {
			count = count * 10 + (*cur - '0');
			cur++;
		}
		addcount(&hash[h & (NBucket-1)], key, count);
		cur = memchr(cur, '\n', endp-cur);
	} while (cur && ++cur != endp);

	// printf("Done %zd - %zd\n", beg, end);
	return 0;
}

int
main(int ac, char *av[])
{
	struct stat s;
	int fd, max, cnt;
	size_t cur, chunk, fsz, n, i;
	char *nl, *maxk;
	Worker *pw;
	Bucket *b;

	if (ac < 2)
		die("no argument\n");

	fd = open(av[1], O_RDONLY);
	if (fd == -1)
		die("cannot open file\n");
	if (fstat(fd, &s))
		die("cannot stat file\n");
	fsz = s.st_size;
	data = mmap(0, fsz, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
	if (data == MAP_FAILED)
		die("cannot mmap file\n");

	/* start workers */
	chunk = fsz / NWorkers;
	cur = 0;
	for (pw=w; pw<&w[NWorkers]; pw++) {
		pw->beg = cur;
		cur += chunk;
		if (cur > fsz)
			cur = fsz;
		nl = memchr(&data[cur-1], '\n', fsz-cur+1);
		if (nl)
			cur = nl - data + 1;
		pw->end = cur;
		pthread_create(&pw->thread, 0, worker, pw);
	}
	assert(cur == fsz);

	/* wait for all threads to be done */
	for (pw=w; pw<&w[NWorkers]; pw++)
		pthread_join(pw->thread, 0);

	max = 0;
	maxk = "oops";
	/* aggregate results */
	for (pw=&w[1]; pw<&w[NWorkers]; pw++) {
		for (n=0; n<NBucket; n++) {
			b = &pw->hash[n];
			for (i=0; i<b->size; i++) {
				cnt = addcount(&w[0].hash[n], b->key[i], b->count[i]);
				if (cnt > max) {
					max = cnt;
					maxk = b->key[i];
				}
			}
		}
	}

	printf("max_key: %s sum: %d\n", maxk, max);
	return 0;
}
