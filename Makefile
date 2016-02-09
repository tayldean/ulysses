DIR_RESULTS = results
DIR_BUILD   = build

RESULTS = $(shell ls $(DIR_RESULTS)/*.results)
SCORES = $(addsuffix .scores,$(addprefix $(DIR_BUILD)/,\
	$(basename $(notdir $(RESULTS)))))

vpath %.results $(DIR_RESULTS)

all: $(SCORES)

$(DIR_BUILD)/%.scores: %.results
	./parse.pm $< $@

$(DIR_BUILD)/%.html: $(DIR_BUILD)/%.scores
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
