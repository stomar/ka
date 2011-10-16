#### Start of system configuration section. ####

srcdir = .

SHELL = /bin/sh
TEX = latex

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_DIR = $(srcdir)/mkinstalldirs

prefix = /usr/local/share/texmf

docdir = $(prefix)/doc
dvipsdir = $(prefix)/dvips
fontsdir = $(prefix)/fonts
texdir = $(prefix)/tex/latex

#### End of system configuration section. ####

SRCS = ka.dtx
AUX  = ka.ins ka.pdf example.tex Makefile ChangeLog README mkinstalldirs
DOCS = ka.cfg ka.dvi ka.ps example.dvi
LOGS  = ka.aux ka.log \
        ka.glo ka.gls \
        ka.idx ka.ilg ka.ind \
        example.aux example.log


ka.sty : ka.dtx ka.ins
	$(TEX) ka.ins

ka.ins : ka.dtx
	$(TEX) ka.dtx

.PHONY : sty
sty : ka.sty

.PHONY : doc
doc : ka.pdf

ka.pdf : ka.dtx
	latex ka.dtx
	latex ka.dtx
	makeindex -s gind ka
	makeindex -s gglo.ist -o ka.gls ka.glo
	latex ka.dtx
	dvips -Ppdf ka.dvi
	ps2pdf -sPAPERSIZE=a4 ka.ps
	dvips ka.dvi

.PHONY : test
test : example.tex ka.sty
	latex example.tex
	latex example.tex

.PHONY : all
all : sty doc test

.PHONY : clean
clean :
	@rm -f $(LOGS)

.PHONY : distclean
distclean : clean
	@rm -f ka.sty $(DOCS)

.PHONY : installdirs
installdirs : mkinstalldirs
	$(INSTALL_DIR) $(DESTDIR)$(docdir)
	$(INSTALL_DIR) $(DESTDIR)$(texdir)

.PHONY : install
install : sty doc installdirs
	$(INSTALL_DATA) ka.pdf $(DESTDIR)$(docdir)
	$(INSTALL_DATA) ka.sty $(DESTDIR)$(texdir)

.PHONY : uninstall
uninstall :
	-cd $(DESTDIR)$(docdir) && rm ka.pdf
	-cd $(DESTDIR)$(texdir) && rm ka.sty

DATE := `date +%Y-%m-%d`
VERSION := `sed \
             -e '/ProvidesPackage{.*}/!d' \
             -e 's/.*v\([0-9.]*\).*/\1/' \
             -e q ka.dtx`

.PHONY : dist
dist: $(SRCS) $(AUX)
	echo ka-$(VERSION)-$(DATE) > .fname
	-rm -rf `cat .fname`
	mkdir `cat .fname`
	ln $(SRCS) $(AUX) `cat .fname`
	tar -chzf `cat .fname`.tar.gz `cat .fname`
	-rm -rf `cat .fname` .fname
