
SRC.proc = 

PSQL=/usr/local/bin/psql

.PHONY: proc

all: proc

proc:
.for f in $(SRC.proc)
	$(PSQL) $(PSQLFLAGS) -f $f
.endfor
