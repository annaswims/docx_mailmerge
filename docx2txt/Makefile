#
# Makefile for docx2txt
#

BINDIR ?= /usr/local/bin
CONFIGDIR ?= /etc

INSTALL = $(shell which install 2>/dev/null)
ifeq ($(INSTALL),)
$(error "Need 'install' to install docx2txt")
endif

PERL = $(shell which perl 2>/dev/null)
ifeq ($(PERL),)
$(warning "*** Make sure 'perl' is installed and is in your PATH, before running the installed script. ***")
endif

BINFILES = docx2txt.sh docx2txt.pl
CONFIGFILE = docx2txt.config

.PHONY: install installbin installconfig

install: installbin installconfig

installbin: $(BINFILES)
	@echo "Installing script files [$(BINFILES)] in \"$(BINDIR)\" .."
	@[ -d "$(BINDIR)" ] || mkdir -p "$(BINDIR)"
	$(INSTALL) -m 755 $^ "$(BINDIR)"
ifneq ($(PERL),)
	@echo "Setting systemConfigDir to [$(CONFIGDIR)] in \"$(BINDIR)/docx2txt.pl\" .."
	$(PERL) -pi -e "s%\"/etc\";%\"$(CONFIGDIR)\";%" "$(BINDIR)/docx2txt.pl"\
	&& rm -f "$(BINDIR)/docx2txt.pl.bak"
else
	@echo "*** Set systemConfigDir to \"$(CONFIGDIR)\" in \"$(BINDIR)/docx2txt.pl\"."
endif

installconfig: $(CONFIGFILE)
	@echo "Installing config file [$(CONFIGFILE)] in \"$(CONFIGDIR)\" .."
	@[ -d "$(CONFIGDIR)" ] || mkdir -p "$(CONFIGDIR)"
	$(INSTALL) -m 755 $^ "$(CONFIGDIR)"
