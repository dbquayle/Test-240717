
SRC.schema = summary.sql
SRC.tables = summary-bank.sql summary-entity.sql summary-account.sql \
	summary-xfer.sql

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
