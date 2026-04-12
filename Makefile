SHELL := /bin/bash

# LaTeX toolchain
LATEXMK ?= latexmk
LATEXMK_FLAGS ?= -pdf -interaction=nonstopmode -halt-on-error
PDFLATEX ?= pdflatex
PDFLATEX_FLAGS ?= -interaction=nonstopmode -halt-on-error

# Detect chapters automatically: any top-level folder that contains "src"
CHAPTER_SRC_DIRS := $(wildcard */src)
CHAPTERS := $(patsubst %/src,%,$(CHAPTER_SRC_DIRS))

# Collect all tex files
TEX_FILES := $(foreach ch,$(CHAPTERS),$(wildcard $(ch)/src/*.tex))

.PHONY: help all build run list chapter new-exercise new clean clean-all

help:
	@echo "Available targets:"
	@echo "  make build              Build all chapter PDFs"
	@echo "  make run                Alias of build"
	@echo "  make list               List detected chapters"
	@echo "  make chapter CHAPTER=X  Build one chapter (e.g. CHAPTER=Introduction)"
	@echo "  make new-exercise CHAPTER=X EXERCISE=Y  Create CHAPTER/src/Y.tex from template"
	@echo "  make new CHAPTER=X EXERCISE=Y           Alias of new-exercise"
	@echo "  make clean              Remove LaTeX aux files"
	@echo "  make clean-all          Remove aux files and generated PDFs"

all: build

build:
	@if [ -z "$(TEX_FILES)" ]; then \
		echo "No .tex files found in chapter src/ folders."; \
		exit 0; \
	fi
	@for tex in $(TEX_FILES); do \
		chapter_dir=$${tex%/src/*}; \
		out_dir=$$chapter_dir/pdf; \
		mkdir -p $$out_dir; \
		echo "Building $$tex -> $$out_dir/"; \
		if command -v $(LATEXMK) >/dev/null 2>&1; then \
			$(LATEXMK) $(LATEXMK_FLAGS) -outdir=$$out_dir $$tex || exit $$?; \
		elif command -v $(PDFLATEX) >/dev/null 2>&1; then \
			$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=$$out_dir $$tex || exit $$?; \
			$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=$$out_dir $$tex || exit $$?; \
		else \
			echo "Error: neither '$(LATEXMK)' nor '$(PDFLATEX)' is installed."; \
			exit 127; \
		fi; \
	done

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
	@if ! ls "$(CHAPTER)/src"/*.tex >/dev/null 2>&1; then \
		echo "No .tex files found in $(CHAPTER)/src/."; \
		exit 0; \
	fi
	@mkdir -p "$(CHAPTER)/pdf"
	@for tex in $(wildcard $(CHAPTER)/src/*.tex); do \
		echo "Building $$tex -> $(CHAPTER)/pdf/"; \
		if command -v $(LATEXMK) >/dev/null 2>&1; then \
			$(LATEXMK) $(LATEXMK_FLAGS) -outdir=$(CHAPTER)/pdf $$tex || exit $$?; \
		elif command -v $(PDFLATEX) >/dev/null 2>&1; then \
			$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=$(CHAPTER)/pdf $$tex || exit $$?; \
			$(PDFLATEX) $(PDFLATEX_FLAGS) -output-directory=$(CHAPTER)/pdf $$tex || exit $$?; \
		else \
			echo "Error: neither '$(LATEXMK)' nor '$(PDFLATEX)' is installed."; \
			exit 127; \
		fi; \
	done

new-exercise new:
	@if [ -z "$(CHAPTER)" ] || [ -z "$(EXERCISE)" ]; then \
		echo "Usage: make new-exercise CHAPTER=<chapter-folder> EXERCISE=<name>"; \
		exit 1; \
	fi
	@if [ ! -f template.tex ]; then \
		echo "template.tex not found in repository root."; \
		exit 1; \
	fi
	@mkdir -p "$(CHAPTER)/src" "$(CHAPTER)/pdf"
	@if [ -e "$(CHAPTER)/src/$(EXERCISE).tex" ]; then \
		echo "$(CHAPTER)/src/$(EXERCISE).tex already exists."; \
		exit 1; \
	fi
	@cp template.tex "$(CHAPTER)/src/$(EXERCISE).tex"
	@sed -i "s/exercise-id/$(EXERCISE)/g" "$(CHAPTER)/src/$(EXERCISE).tex"
	@echo "Created $(CHAPTER)/src/$(EXERCISE).tex from template.tex"

clean:
	@for ch in $(CHAPTERS); do \
		rm -f $$ch/pdf/*.aux $$ch/pdf/*.bbl $$ch/pdf/*.bcf $$ch/pdf/*.blg $$ch/pdf/*.fdb_latexmk $$ch/pdf/*.fls $$ch/pdf/*.log $$ch/pdf/*.out $$ch/pdf/*.run.xml $$ch/pdf/*.synctex.gz $$ch/pdf/*.toc $$ch/pdf/*.xdv $$ch/pdf/*.xsim; \
	done
	@echo "Auxiliary files cleaned."

clean-all: clean
	@for ch in $(CHAPTERS); do \
		rm -f $$ch/pdf/*.pdf; \
	done
	@echo "Generated PDFs cleaned."
