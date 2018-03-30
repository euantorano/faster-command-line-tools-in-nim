# build image

FROM nimlang/nim:latest-alpine AS build-env

WORKDIR /app

COPY csv_test.nim .

RUN nim c -d:release -o:csv_test csv_test.nim

# runtime image

FROM alpine:latest

WORKDIR /app

COPY --from=build-env /app/csv_test .

VOLUME ['/data', '/output', '/resources']

RUN apk add --no-cache bash

CMD /resources/run.sh nim.txt
