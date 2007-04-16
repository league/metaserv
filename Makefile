# Makefile for "MetaOCaml Server Pages" prototype & benchmarking system.
# Copyright (c) 2004 Christopher League <christopher.league@liu.edu>

###################################################################
###  Programs and settings

# Where is MetaOCaml installed?  Include full path to bin/ directory.
METADIR = $(HOME)/tmp/metaocaml/bin

# Names of MetaOCaml batch compiler and interactive top-level system.
OCAML = $(METADIR)/metaocaml
OCAMLC = $(METADIR)/ocamlc
OCAMLOPT = $(METADIR)/ocamlopt
OCAMLDEP = $(METADIR)/ocamldep
MLFLAGS = -I +threads -I server
CFLAGS = -thread

# The Meta->ML compiler is written in Standard ML.
SML = $(HOME)/tmp/nj/bin/sml
CM = .cm

# Other required programs
PERL = perl
PHP = php
NOHUP = nohup
ENCODE = uuencode -m -
GNUPLOT = gnuplot
CONVERT = convert
EPSTOPDF = epstopdf
TEXI2DVI = texi2dvi -b
TEXI2PDF = texi2pdf -b
DVIPS = dvips
PSBIND = psbind
LGRIND = lgrind -d paper/lgrindef 
LSED = sed -f paper/lgrindsub

# Sizes to generate for benchmarking, etc.
static_sizes = 01 02 04 08 16 32 64
dir_sizes    =    02 04 08 16 32 64
power_cases  = 17 127 255 511 1023 2047 4095 8191

###################################################################
###  Top-level rules

default: server/server.cma  scripts/run
# server/nativeserver

LIBS = unix str nums threads
OCAMLCMD = $(OCAML) $(MLFLAGS) $(addsuffix .cma, $(LIBS)) server.cma

all: default $(addprefix bench/d., $(dir_sizes)) server.log

server.log:
	touch $@

run: all
	$(OCAMLCMD) scripts/run
daemon: all
	$(NOHUP) $(OCAMLCMD) scripts/run &

interact: default
	$(OCAMLCMD)

staged_php := $(addprefix bench/d-, $(addsuffix .php, $(dir_sizes)))
bench: $(staged_php)

pdf: paper/paper.pdf
ps: paper/paper.ps
2ps: paper/paper.2ps
dvi: paper/paper.dvi

talk_figs := dot dot2 dot3 dot4 dotst first prn decl trans trans2
talk_figs_pdf := $(addprefix talk/, $(addsuffix .pdf, $(talk_figs)))
talk: $(talk_figs_pdf)

tex_junk = aux bbl blg log out waux
texclean:
	$(RM) $(addprefix paper/paper., $(tex_junk))
	$(RM) $(addprefix talk/skeleton., $(tex_junk))
	$(RM) talk/tmp.tex

mostlyclean: texclean
	find . -name '*~' | xargs $(RM)
	$(RM) server.log paper/missfont.log
	$(RM) -r metac/$(CM)

clean: mostlyclean
	$(RM) metac/metac.*-* server/*.cm? server/*.o $(staged_php)
	$(RM) scripts/run scripts/trans.ml $(ml_files) server/nativeserver
	$(RM) $(screens_png) $(screens_eps) $(listings_tex)
	$(RM) $(figs_tex) $(figs_eps) $(figs_pdf) $(talk_figs_pdf)
	$(RM) $(addprefix paper/paper., dvi wdvi ps 2ps)
	$(RM) -r paper/auto paper/_whizzy* paper/._whizzy*

reallyclean: clean
	$(RM) metac/meta.grm.* metac/meta.lex.*
	$(RM) Makefile.depend scripts/static*.meta paper/paper.pdf
	$(RM) -r bench/d.??

.PHONY: default run interact pdf ps mostlyclean clean reallyclean

###################################################################
###  Implicit rules

# MetaOCaml object files and libraries
%.cma:
	$(OCAMLC) -a -o $@ $^
%.cmi: %.mli
	$(OCAMLC) $(CFLAGS) $(MLFLAGS) -c $<
%.cmo: %.ml
	$(OCAMLC) $(CFLAGS) $(MLFLAGS) -c $<
%.cmx: %.ml
	$(OCAMLOPT) $(CFLAGS) $(MLFLAGS) -c $<

# New Jersey heap file
ifeq ($(shell uname), Darwin)
  HEAP = ppc-darwin
else
  HEAP = x86-linux
endif
# XYZ.cm must define Main.main, which is exported as XYZ.HEAP
%.$(HEAP): %.cm
	echo 'SMLofNJ.exportFn("$@", Main.main);' | $(SML) -m $<

# Turn .meta server pages into .ml programs using metac program.
%.ml: %.meta metac/metac.$(HEAP)
	$(SML) @SMLload=metac/metac $<

# These are useful for generating random files and directories of
# given size.
scripts/static%.meta:
	$(ENCODE) </dev/urandom | dd bs=1024 count=$* >$@
bench/d.%:
	cd bench && $(PERL) make-sim-dir $*
bench/d-%.php: bench/d.% bench/dir-staged.php
	$(PHP) bench/dir-staged.php $< >$@

# Image conversion
%.png: %.tiff
	$(CONVERT) $< -crop 0x0 $@
%.eps: %.png
	$(CONVERT) $< $@
%.pdf: %.eps
	$(EPSTOPDF) $<

# GNUplot
paper/%.eps paper/%.tex: bench/%.gp bench/*.dat
	cd bench && $(GNUPLOT) $*.gp
	mv bench/$*.eps paper
	mv bench/$*.tex paper

# LaTeX
.DELETE_ON_ERROR:
%.pdf: %.tex
	cd $(dir $<) && $(TEXENV) $(TEXI2PDF) $(notdir $<)
%.dvi: %.tex
	cd $(dir $<) && $(TEXENV) $(TEXI2DVI) $(notdir $<)
%.ps: %.dvi
	cd $(dir $<) && \
	$(TEXENV) $(DVIPS) -o $(notdir $@) $(notdir $<)
%.2ps: %.ps
	$(PSBIND) $< >$@
%.eps: %.dvi
	cd $(dir $<) && \
	$(TEXENV) $(DVIPS) -E -o $(notdir $@) $(notdir $<)

# code -> LaTeX
LGRIND_CFG := paper/lgrindef paper/lgrindsub
LGRIND_OCAML = $(LGRIND) -i -lOCaml $< | $(LSED) >$@
paper/%.ml.tex: scripts/%.ml $(LGRIND_CFG)
	$(LGRIND_OCAML)
paper/%.mli.tex: server/%.mli $(LGRIND_CFG)
	$(LGRIND_OCAML)
talk/%.lg: talk/%.ml $(LGRIND_CFG)
	$(LGRIND_OCAML)
talk/%.lg: talk/%.meta $(LGRIND_CFG)
	(echo '?>RM'; cat $<; echo 'RM<?') \
	  | $(LGRIND) -i -lMeta - | $(LSED) >$@
paper/%.meta.tex: scripts/%.meta $(LGRIND_CFG)
	(echo '?>RM'; cat $<; echo 'RM<?') \
	  | $(LGRIND) -i -lMeta - | $(LSED) >$@

talk/%.dvi: talk/%.lg talk/skeleton.tex paper/fonts.tex
	cp $< talk/tmp.tex
	cd talk && $(TEXENV) $(TEXI2DVI) skeleton.tex
	mv talk/skeleton.dvi $@

#paper/%.tex: paper/%.ltx $(LGRIND_CFG)
#	$(LGRIND) -e -a -lOCaml $< | $(LSED) >$@

###################################################################
###  Dependencies

# for server:
include Makefile.depend

server_modules := chunked timeStamp stringMap stringSet status request \
		  logFile server fileHandler codeHandler navBar navspec \
		  dirHof dirUn powHof powHof2 powUnstaged hofMap
server_modules := $(addprefix server/, $(server_modules))
server_objects := $(addsuffix .cmo, $(server_modules))
server_sources := $(addsuffix .ml, $(server_modules))

server/server.cma: $(server_objects)
Makefile.depend: $(server_sources)
	$(OCAMLDEP) $(MLFLAGS) $^ >$@

server/nativeserver: $(addsuffix .cmx, $(server_modules)) server/hofMain.cmx
	$(OCAMLOPT) $(MLFLAGS) -o $@ $(addsuffix .cmxa, $(LIBS)) $^

# for metac:
metac_sources := $(addprefix metac/, $(shell tail +2 metac/metac.cm))
metac/metac.$(HEAP): $(metac_sources)

# for paper:
figures := $(addprefix paper/, static browse hofbrowse power)
figs_tex := $(addsuffix .tex, $(figures))
figs_eps := $(addsuffix .eps, $(figures))
figs_pdf := $(addsuffix .pdf, $(figures))

screens := $(addprefix paper/, confcal power127 server-dir gc)
screens_png := $(addsuffix .png, $(screens))
screens_eps := $(addsuffix .eps, $(screens))

listings := trans.ml navspec-sig.ml powerhof.ml dir-out.ml \
  size-out.ml codeHndl.mli \
  $(addsuffix .meta, first pi size size2 size3 perm perm2 perm3 \
    count count2 power dir gc trans)
listings_tex := $(addprefix paper/, $(addsuffix .tex, $(listings)))

TEXENV = 
tex_files = paper/fonts.tex paper/refs.bib $(figs_tex) $(listings_tex)
paper/paper.pdf: $(tex_files) $(screens_png) $(figs_pdf)
paper/paper.dvi: $(tex_files) $(screens_eps) $(figs_eps)

###################################################################
###  Generating code map and run script 

plain_pages := /gc/Gc /Index /about/About /uname/Uname \
  /uptime/Uptime /http/Http /first/First /pi/Pi /perm/Perm \
  /perm2/Perm2 /perm3/Perm3 /count/Count /checkme/Checkme \
  /size/Size /size2/Size2 /size3/Size3
#/testme/Testme
dir_pages := metac paper scripts server bench images

script_names := dir dirUn dirNoMd5 dirUnNoMd5 power powerUn count2 \
  $(addprefix static, $(static_sizes)) \
  $(notdir $(shell echo $(plain_pages) | tr '[A-Z]' '[a-z]'))

script_files := $(addprefix scripts/, $(script_names))
meta_files := $(addsuffix .meta, $(script_files))
ml_files := $(addsuffix .ml, $(script_files))

.PRECIOUS: $(meta_files)

scripts/run: Makefile $(ml_files) scripts/run_
	echo '#use "scripts/navspec.ml";;' >$@
	for x in $(ml_files); do \
	  echo '#use "'$$x'";;'   >>$@; \
	done
	echo 'let code_list = ['          >>$@
	for p in $(plain_pages); do \
	  echo "\"`dirname $$p`\", (fun () -> .! `basename $$p`.page);"  >>$@; \
	done
	for c in $(power_cases); do \
	  echo -n "\"/power$$c\", "                 >>$@; \
	  echo    "(fun () -> .! Power.page (Num.Int $$c));"    >>$@; \
	  echo -n "\"/powerun$$c\", "               >>$@; \
	  echo    "(fun () -> .! PowerUn.page (Num.Int $$c));"  >>$@; \
	done
	for z in $(static_sizes); do \
	  echo "\"/static$$z\", (fun () -> .! Static$$z.page);" >>$@; \
	done
	for d in $(dir_sizes); do \
	  echo "\"/browse$$d\", (fun () -> .! Dir.page \"\" \"bench/d.$$d\");" >>$@; \
	  echo "\"/unbrowse$$d\", (fun () -> .! DirUn.page \"\" \"bench/d.$$d\");" >>$@; \
	  echo "\"/nobrowse$$d\", (fun () -> .! DirNoMd5.page \"\" \"bench/d.$$d\");" >>$@; \
	  echo "\"/nounbrowse$$d\", (fun () -> .! DirUnNoMd5.page \"\" \"bench/d.$$d\");" >>$@; \
	done
	echo "\"/browse\", (fun () -> .! Dir.page \"/browse\" \".\");" >>$@
	for d in $(dir_pages); do \
	  echo "\"/$$d/\", (fun () -> .! Dir.page \"/$$d/\" \"$$d\");" >>$@; \
	done
	echo "\"/longcount\", (fun () -> .! Count2.page 99);" >>$@;
	echo "\"/shortcount\", (fun () -> .! Count2.page 9);" >>$@;
	echo '];;'          >>$@
	cat scripts/run_    >>$@

