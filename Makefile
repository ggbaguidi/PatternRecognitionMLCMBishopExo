SHELL := /bin/bash

# LaTeX toolchain
LATEXMK ?= latexmk
LATEXMK_FLAGS ?= -pdf -interaction=nonstopmode -halt-on-error

# Detect chapters automatically: any top-level folder that contains "src"
CHAPTER_SRC_DIRS := $(wildcard */src)
CHAPTERS := $(patsubst %/src,%,$(CHAPTER_SRC_DIRS))

# Collect all tex files and their corresponding output PDFs
TEX_FILES := $(foreach ch,$(CHAPTERS),$(wildcard $(ch)/src/*.tex))
PDF_FILES := $(patsubst %/src/%.tex,%/pdf/%.pdf,$(TEX_FILES))

.PHONY: help all build run list chapter clean clean-all

help:
	@echo "Available targets:"
	@echo "  make build              Build all chapter PDFs"
	@echo "  make run                Alias of build"
	@echo "  make list               List detected chapters"
	@echo "  make chapter CHAPTER=X  Build one chapter (e.g. CHAPTER=Introduction)"
	@echo "  make clean              Remove LaTeX aux files"
	@echo "  make clean-all          Remove aux files and generated PDFs"

all: build

build: $(PDF_FILES)

# "run" process requested: compile everything
run: build

list:
	@if [ -z "$(CHAPTERS)" ]; then \
		echo "No chapters found (expected folders with src/)."; \
	else \
		echo "Detected chapters:"; \
		for c in $(CHAPTERS); do echo " - $$c"; done; \
	fi

chapter:
	@if [ -z "$(CHAPTER)" ]; then \
		echo "Usage: make chapter CHAPTER=<chapter-folder>"; \
		exit 1; \
	fi
	@if [ ! -d "$(CHAPTER)/src" ]; then \
		echo "Chapter '$(CHAPTER)' not found or missing src/."; \
		exit 1; \
	fi
	@$(MAKE) $(patsubst $(CHAPTER)/src/%.tex,$(CHAPTER)/pdf/%.pdf,$(wildcard $(CHAPTER)/src/*.tex))

# Generic rule: chapter/src/file.tex -> chapter/pdf/file.pdf
%/pdf/%.pdf: %/src/%.tex | %/pdf
	@echo "Building $< -> $@"
	@$(LATEXMK) $(LATEXMK_FLAGS) -outdir=$(dir $@) $<

# Ensure output directory exists
%/pdf:
	@mkdir -p $@

clean:
	@for ch in $(CHAPTERS); do \
		rm -f $$ch/pdf/*.aux $$ch/pdf/*.bbl $$ch/pdf/*.bcf $$ch/pdf/*.blg $$ch/pdf/*.fdb_latexmk $$ch/pdf/*.fls $$ch/pdf/*.log $$ch/pdf/*.out $$ch/pdf/*.run.xml $$ch/pdf/*.synctex.gz $$ch/pdf/*.toc $$ch/pdf/*.xdv; \
	done
	@echo "Auxiliary files cleaned."

clean-all: clean
	@for ch in $(CHAPTERS); do \
		rm -f $$ch/pdf/*.pdf; \
	done
	@echo "Generated PDFs cleaned."
