DIR_RESULTS = results
DIR_BUILD   = build

COMPETITIONS = $(patsubst %.results,%.out,$(wildcard results/*.results))
PDFS = $(patsubst %.results,%.pdf,$(wildcard results/*.results))
TEXS = $(patsubst %.results,%.tex,$(wildcard results/*.results))
DATS = $(patsubst %.results,%.dat,$(wildcard results/*.results))

.SUFFIXES: .results .out .pdf

.PRECIOUS: $(TEXS) $(DATS)

all: $(DATS)

%.dat: %.results
	./parse.pm $<

%.tex: %.dat
	./write_tex.pm $@

%.pdf: %.tex
	pdflatex -output-directory $(DIR_RESULTS) $<

publish:
	find $(DIR_RESULTS) -regex ".+\.scores" | sort | tail -n1 | xargs cat > \
	$(DIR_RESULTS)/index.html
	git checkout gh-pages
	cp $(DIR_RESULTS)/index.html .
	git add index.html && git commit -m "Update index.html" && git push
	git checkout master

clean:
	cd $(DIR_RESULTS) && \
	rm -f *.log *.aux *.pdf *.toc *.snm *.vrb *.scores *.tex *.swp *.dat *~
