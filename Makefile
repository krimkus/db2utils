DBNAME:=SAMPLE
SCHEMANAME:=UTILS

VERSION:=0.2
ALL_EXT:=$(wildcard pcre/*.c) $(wildcard pcre/*.h)
ALL_TESTS:=$(wildcard tests/*.sql)
ALL_SQL:=$(filter-out install.sql uninstall.sql,$(wildcard *.sql))
ALL_FOO:=$(ALL_SQL:%.sql=%.foo)

install: install.sql
	$(MAKE) -C pcre install
	printf "CONNECT TO $(DBNAME);\nCREATE SCHEMA $(SCHEMANAME);\nCOMMIT;\n" | db2 +c +p -t || true
	db2 -td! +c -s -vf $< || [ $$? -lt 4 ] && true

uninstall: uninstall.sql
	db2 -td! +c +s -vf $< || true
	printf "CONNECT TO $(DBNAME);\nDROP SCHEMA $(SCHEMANAME) RESTRICT;\nCOMMIT;\n" | db2 +c +p -t || true
	$(MAKE) -C pcre uninstall

doc:
	$(MAKE) -C docs html

test:
	$(MAKE) -C tests test DBNAME=$(DBNAME) SCHEMANAME=$(SCHEMANAME)

clean: $(SUBDIRS)
	$(MAKE) -C docs clean
	$(MAKE) -C pcre clean
	$(MAKE) -C tests clean
	rm -f foo
	rm -f *.foo
	rm -f utils.sql
	rm -f install.sql
	rm -f uninstall.sql
	rm -fr build/ dist/

utils.sql: utils.sqt Makefile
	sed -e 's/%SCHEMANAME%/$(SCHEMANAME)/' $< > $@

%.foo: %.sql
	cat $< >> foo
	touch $@

install.sql: $(ALL_FOO)
	echo "CONNECT TO $(DBNAME)!" > $@
	echo "SET SCHEMA $(SCHEMANAME)!" >> $@
	echo "SET PATH SYSTEM PATH, $(SCHEMANAME), USER!" >> $@
	cat foo >> $@
	echo "COMMIT!" >> $@
	rm foo
	rm -f *.foo

uninstall.sql: install.sql
	echo "CONNECT TO $(DBNAME)!" > $@
	echo "SET SCHEMA $(SCHEMANAME)!" >> $@
	echo "SET PATH SYSTEM PATH, $(SCHEMANAME), USER!" >> $@
	awk -f uninstall.awk $< | tac >> $@
	echo "COMMIT!" >> $@

assert.foo: utils.foo sql.foo

date_time.foo: utils.foo assert.foo

export_load.foo: utils.foo sql.foo

exceptions.foo: utils.foo sql.foo auth.foo

evolve.foo: utils.foo sql.foo auth.foo

auth.foo: utils.foo sql.foo

drop_schema.foo: utils.foo sql.foo

merge.foo: utils.foo assert.foo sql.foo

history.foo: utils.foo sql.foo auth.foo date_time.foo assert.foo

corrections.foo: utils.foo sql.foo log.foo

toggle_triggers.foo: utils.foo sql.foo assert.foo

sql.foo: utils.foo

.PHONY: install uninstall doc clean test
