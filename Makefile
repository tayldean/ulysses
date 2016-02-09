DIR_RESULTS = results
DIR_BUILD   = build

COMPETITIONS = $(patsubst %.results,%.out,$(wildcard results/*.results))
PDFS = $(patsubst %.results,%.pdf,$(wildcard results/*.results))
TEXS = $(patsubst %.results,%.tex,$(wildcard results/*.results))
DATS = $(patsubst %.results,%.dat,$(wildcard results/*.results))
SCORES = $(patsubst %.results,%.scores,$(wildcard results/*.results))

.SUFFIXES: .results .out .pdf

.PRECIOUS: $(TEXS) $(DATS)

vpath %.scores $(DIR_RESULTS)

all: $(DATS)

%.scores: %.resutls
	./parse.pm $< $@

$(DIR_BUILD)/%.html: %.scores
	./results-to-html.pm $< $@

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
