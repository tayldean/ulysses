DIR_RESULTS = results
DIR_BUILD   = build
DIR_SCRIPTS = scripts

PARSE = $(DIR_SCRIPTS)/parse.pm
GEN_HTML = $(DIR_SCRIPTS)/results-to-html.pm

RESULTS = $(shell ls $(DIR_RESULTS)/*.results)
SCORES = $(addsuffix .scores,$(addprefix $(DIR_BUILD)/,\
	$(basename $(notdir $(RESULTS)))))
HTMLS = $(addsuffix .html,$(basename $(SCORES)))

RESULT_NEWEST = $(shell find $(DIR_RESULTS) -regex ".+\.results" | \
	sort | tail -n1)
HTML_NEWEST = $(addsuffix .html,$(addprefix $(DIR_BUILD)/,\
	$(notdir $(basename $(RESULT_NEWEST)))))

.PRECIOUS: $(DIR_BUILD)/%.scores

.PHONY: all clean publish

vpath %.results $(DIR_RESULTS)

all: $(HTMLS)

$(DIR_BUILD)/%.scores: %.results
	$(PARSE) $< $@

$(DIR_BUILD)/%.html: $(DIR_BUILD)/%.scores
	$(GEN_HTML) $< $@

publish: $(HTML_NEWEST)
	cat $< > $(DIR_BUILD)/index.html
	git checkout gh-pages
	cp $(DIR_BUILD)/index.html .
	git status | grep "Changes not staged for commit" 2>&1 > /dev/null
	if [ $? -eq 0 ]; then
		git add index.html && git commit -m "Update index.html" && git push
	fi
	git checkout master

clean:
	rm -rf $(DIR_BUILD)/*
