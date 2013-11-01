#
# BSD makefile for docx2txt
#

BINDIR ?= /usr/local/bin
CONFIGDIR ?= /etc

INSTALL != which install

BINFILES = docx2txt.sh docx2txt.pl
CONFIGFILE = docx2txt.config

.PHONY: install installbin installconfig

install: installbin installconfig

installbin: $(BINFILES)
	[ -d $(BINDIR) ] || mkdir -p $(BINDIR)
	$(INSTALL) -m 755 $> $(BINDIR)

installconfig: $(CONFIGFILE)
	[ -d $(CONFIGDIR) ] || mkdir -p $(CONFIGDIR)
	$(INSTALL) -m 755 $> $(CONFIGDIR)
