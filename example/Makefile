JASMIN=jasminc
JFLAGS=-lea

main: main.c addvec.s
	gcc -Wall -Wextra -Wpedantic main.c addvec.s -o $@

%.s: %.jazz
	$(JASMIN) -o $@ $(JFLAGS) $^

.PHONY: clean

clean:
	-rm main
