COMPETITIONS = $(patsubst %.results,%.out,$(wildcard results/*.results))

.SUFFIXES: .results .out

all: $(COMPETITIONS)

%.out: %.results
	./parse.pm $<

clean: 
	rm -rf results/*.out
