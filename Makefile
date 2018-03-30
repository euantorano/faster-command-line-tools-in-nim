CURRENT_DIR=$(shell pwd)

c_image:
	@docker build -f ./C/Dockerfile.gcc -t csv_test_c_gcc ./C/
	@docker build -f ./C/Dockerfile.clang -t csv_test_c_clang ./C/

d_image:
	@docker build -f ./D/Dockerfile.dmd -t csv_test_d_dmd ./D/
	@docker build -f ./D/Dockerfile.ldc -t csv_test_d_ldc ./D/

go_image:
	@docker build -t csv_test_go ./Go/

nim_image:
	@docker build -t csv_test_nim ./Nim/

python_image:
	@docker build -f ./Python/Dockerfile.python2 -t csv_test_python2 ./Python/
	@docker build -f ./Python/Dockerfile.python3 -t csv_test_python3 ./Python/

build: c_image d_image go_image nim_image python_image

data/ngrams.tsv:
	@mkdir -p data
	@curl --output ./data/ngrams.gz https://storage.googleapis.com/books/ngrams/books/googlebooks-eng-all-1gram-20120701-0.gz
	@gunzip ./data/ngrams.gz
	@mv ./data/ngrams  ./data/ngrams.tsv

c_run: c_image data/ngrams.tsv
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_c_gcc
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_c_clang

d_run: d_image data/ngrams.tsv
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_d_dmd
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_d_ldc

go_run: go_image data/ngrams.tsv
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_go

nim_run: nim_image data/ngrams.tsv
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_nim

python_run: python_image data/ngrams.tsv
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_python2
	@docker run --rm -v $(CURRENT_DIR)/data:/data:ro -v $(CURRENT_DIR)/output:/output -v $(CURRENT_DIR)/resources:/resources:ro csv_test_python3

run: c_run d_run go_run nim_run python_run
	@printf "C (GCC):\n\n" > output/results.txt
	@cat output/c_gcc.txt >> output/results.txt
	@printf "\nC (clang):\n\n" >> output/results.txt
	@cat output/c_clang.txt >> output/results.txt
	@printf "\nD (DMD):\n\n" >> output/results.txt
	@cat output/d_dmd.txt >> output/results.txt
	@printf "\nD (LDC):\n\n" >> output/results.txt
	@cat output/d_ldc.txt >> output/results.txt
	@printf "\nGo:\n\n" >> output/results.txt
	@cat output/go.txt >> output/results.txt
	@printf "\nNim (GCC):\n\n" >> output/results.txt
	@cat output/nim.txt >> output/results.txt
	@printf "\nPython 2:\n\n" >> output/results.txt
	@cat output/python2.txt >> output/results.txt
	@printf "\nPython 3:\n\n" >> output/results.txt
	@cat output/python3.txt >> output/results.txt
	@cat output/results.txt

clean:
	@rm -Rf data
	@rm -Rf output
	@docker image rm csv_test_c_gcc csv_test_c_clang csv_test_d_dmd csv_test_d_ldc csv_test_go csv_test_nim csv_test_python2 csv_test_python3 2>/dev/null; true

.PHONY: c_image d_image go_image nim_image build clean