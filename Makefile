DESTDIR=
PREFIX=/usr/local
PACKAGE_NAME=names
VER=0.1
TCLSH=tclsh

all: tm docs

tm/$(PACKAGE_NAME)-$(VER).tm: names.tcl
	mkdir -p tm
	cp names.tcl tm/$(PACKAGE_NAME)-$(VER).tm

tm: tm/$(PACKAGE_NAME)-$(VER).tm

docs: doc/$(PACKAGE_NAME).n README.md

install-tm: tm
	mkdir -p $(DESTDIR)$(PREFIX)/lib/tcl8/site-tcl
	cp tm/$(PACKAGE_NAME)-$(VER).tm $(DESTDIR)$(PREFIX)/lib/tcl8/site-tcl/

install-doc: docs
	mkdir -p $(DESTDIR)$(PREFIX)/man
	cp doc/$(PACKAGE_NAME).n $(DESTDIR)$(PREFIX)/man/

install: install-tm install-doc

clean:
	rm -r tm

README.md: doc/$(PACKAGE_NAME).md
	pandoc --standalone --from markdown --to gfm doc/$(PACKAGE_NAME).md --output README.md

doc/$(PACKAGE_NAME).n: doc/$(PACKAGE_NAME).md
	pandoc --standalone --from markdown --to man doc/$(PACKAGE_NAME).md --output doc/$(PACKAGE_NAME).n

test: tm
	$(TCLSH) tests/all.tcl $(TESTFLAGS) -load "source [file join $$::tcltest::testsDirectory .. tm $(PACKAGE_NAME)-$(VER).tm]; package provide $(PACKAGE_NAME) $(VER)"

.PHONY: all clean install install-tm install-doc docs test tm
