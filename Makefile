COMPETITIONS = $(patsubst %.results,%.out,$(wildcard results/*.results))
PDFS = $(patsubst %.results,%.pdf,$(wildcard results/*.results))
TEXS = $(patsubst %.results,%.tex,$(wildcard results/*.results))
DATS = $(patsubst %.results,%.dat,$(wildcard results/*.results))

.SUFFIXES: .results .out .pdf

.PRECIOUS: $(TEXS) $(DATS)

all: $(PDFS)

%.dat: %.results
	./parse.pm $<

%.tex: %.dat
	./write_tex.pm $@

%.pdf: %.tex
	pdflatex -output-directory results $<

clean:
	cd results && rm -f *.log *.aux *.pdf *.toc *.snm *.vrb *.scores *.tex
