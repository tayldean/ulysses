DIR_RESULTS = results
DIR_BUILD   = build
DIR_SCRIPTS = scripts

PARSE = $(DIR_SCRIPTS)/parse.pm
GEN_HTML = $(DIR_SCRIPTS)/results-to-html.pm

RESULTS = $(shell ls $(DIR_RESULTS)/*.results)
SCORES = $(addsuffix .scores,$(addprefix $(DIR_BUILD)/,\
	$(basename $(notdir $(RESULTS)))))
HTMLS = $(addsuffix .html,$(basename $(SCORES)))

vpath %.results $(DIR_RESULTS)

all: $(HTMLS)

$(DIR_BUILD)/%.scores: %.results
	$(PARSE) $< $@

$(DIR_BUILD)/%.html: $(DIR_BUILD)/%.scores
	$(GEN_HTML) $< $@

publish:
	find $(DIR_BUILD) -regex ".+\.html" | sort | tail -n1 | xargs cat > \
	$(DIR_BUILD)/index.html
	git checkout gh-pages
	cp $(DIR_BUILD)/index.html .
	git add index.html && git commit -m "Update index.html" && git push
	git checkout master

clean:
	rm -rf $(DIR_BUILD)/*
