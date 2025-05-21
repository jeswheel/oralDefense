LUALATEX = lualatex
BIBTEX = bibtex
# KNITR = Rscript -e "knitr::knit('%s', output = '%s')"
TEXFILES = $(wildcard */*.tex)

# Directories containing Rnw files
CHAPTER_DIRS = introduction conclusion arima2 haiti mpif

# Create lists of .Rnw and corresponding .tex files
RNW_FILES := $(wildcard $(foreach dir,$(CHAPTER_DIRS),$(dir)/*.Rnw))
TEX_FILES := $(RNW_FILES:.Rnw=.tex)

AUX_EXTENSIONS = log lof fls aux bbl blg fdb_latexmk lop out toc nav snm vrb gz

# Default target
all: main.pdf

# Build the main PDF
main.pdf: main.tex $(TEX_FILES)
	$(LUALATEX) main.tex
	$(BIBTEX) main
	$(LUALATEX) main.tex
	$(LUALATEX) main.tex
	$(MAKE) dust

# Rule to create .tex files from .Rnw
%.tex: %.Rnw
	Rscript -e "knitr::knit('$<', output='$@')"

# Rule to convert .Rnw to .tex using knitr
# %.tex: %.Rnw
# 	$(call KNITR,$<,$@)

# Rule to build PDF from main.tex, including all dependencies
$(PDF_OUTPUT): $(MAIN_TEX) $(TEX_FILES)
	latexmk -pdf $(MAIN_TEX)

# Clean up auxiliary files
clean:
	rm -f *.aux *.log *.nav *.out main.pdf *.snm *.toc *.vrb $(TEX_FILES)

# Specifically clean only the output PDF
cleanpdf:
	rm -f $(PDF_OUTPUT)

# Remove only typical LaTeX auxiliary files
dust:
	rm -f $(foreach ext,$(AUX_EXTENSIONS),*.$(ext))
	$(foreach dir,$(CHAPTER_DIRS), rm -f $(foreach ext,$(AUX_EXTENSIONS),$(dir)/*.$(ext));)
	rm -rf _minted
	# rm -f *.log *.lof *.fls *.aux *.bbl *.blg *.fdb_latexmk *.lop *.out *.toc

.PHONY: all clean cleanpdf dust
