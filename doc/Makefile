DOTSRC=arch.dot
DOTSVG=$(DOTSRC:C/dot$/svg/g)

DOT=/usr/local/bin/dot
DOTFLAGS?=

.SUFFIXES: .dot .svg

.dot.svg: $(.IMPSRC)
	$(DOT) $(DOTFLAGS) -Tsvg -o $(.TARGET) $(.IMPSRC)

all: $(DOTSVG)
