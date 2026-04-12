# Pattern Recognition and Machine Learning — Exercise Solutions

This repository contains my personal solutions to exercises from
*Pattern Recognition and Machine Learning* by Christopher M. Bishop.

## Overview

I solve exercises chapter by chapter and keep each solution as a separate LaTeX file.
Each chapter has:

- `src/` for `.tex` solution files (for example `1.1.tex`, `1.2.tex`)
- `pdf/` for compiled output PDFs

## Repository Structure

```text
.
├── Introduction/
│   ├── src/
│   └── pdf/
├── template.tex
├── Makefile
└── README.md
```

## Solution Template

`template.tex` is a minimal solution template that includes:

- exercise ID placeholder (`exercise-id`)
- book name and author
- my name as author

## Build & Workflow

The project uses `make` to create solution files and compile PDFs.

- `make list`  
	Show detected chapter folders.

- `make new-exercise CHAPTER=<ChapterName> EXERCISE=<id>`  
	Create `CHAPTER/src/<id>.tex` from `template.tex`.

- `make new CHAPTER=<ChapterName> EXERCISE=<id>`  
	Alias for `new-exercise`.

- `make chapter CHAPTER=<ChapterName>`  
	Build all `.tex` files in one chapter.

- `make build` (or `make run`)  
	Build all chapter solutions.

- `make clean`  
	Remove LaTeX auxiliary files.

- `make clean-all`  
	Remove auxiliary files and generated PDFs.

### Example

Create and compile a new solution in `Introduction`:

1. `make new-exercise CHAPTER=Introduction EXERCISE=1.2`
2. Edit `Introduction/src/1.2.tex`
3. `make chapter CHAPTER=Introduction`

## Notes

- The build system tries `latexmk` first and falls back to `pdflatex`.
- PDFs are intentionally kept in the repository.

## Contributing

If you find an error or want to suggest an improvement:

- **Email**: guygbaguidi123root (at) gmail.com
- **Pull Requests**: welcome

## License

This repository contains personal solutions. Please refer to the original book for licensing and rights related to the exercise content.