
SRC.schema = journal.sql
SRC.tables = journal-xlog.sql

PSQL=/usr/local/bin/psql

.PHONY: schema tables

all: schema tables

schema:
.for f in $(SRC.schema)
	$(PSQL) $(PSQLFLAGS) -f $f
.endfor

tables:
.for f in $(SRC.tables)
	$(PSQL) $(PSQLFLAGS) -f $f
.endfor
