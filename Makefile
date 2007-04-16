# Makefile for "MetaOCaml Server Pages" prototype & benchmarking system.
# Copyright (c) 2004 Christopher League <christopher.league@liu.edu>

###################################################################
###  Programs and settings

# Where is MetaOCaml installed?  Include full path to bin/ directory.
METADIR = $(HOME)/tmp/metaocaml/bin

# Names of MetaOCaml batch compiler and interactive top-level system.
OCAMLC = $(METADIR)/ocamlc
OCAML = $(METADIR)/metaocaml
OCAMLDEP = $(METADIR)/ocamldep
MLFLAGS = -I +threads -I server
CFLAGS = -thread -g

# The Meta->ML compiler is written in Standard ML.
SML = $(HOME)/tmp/nj/bin/sml
CM = .cm

# Other required programs
PERL = perl
ENCODE = uuencode -m -
GNUPLOT = gnuplot
CONVERT = convert
EPSTOPDF = epstopdf
TEXI2DVI = texi2dvi
TEXI2PDF = texi2pdf
DVIPS = dvips

# Sizes to generate for benchmarking, etc.
static_sizes = 01 02 04 08 16 32 64
dir_sizes    =    02 04 08 16 32 64
power_cases  = 17 127 255 511 1023 2047 4095 8191

###################################################################
###  Top-level rules

default: server/server.cma scripts/run

LIBS = unix str nums threads server
OCAMLCMD = $(OCAML) $(MLFLAGS) $(addsuffix .cma, $(LIBS))

run: default $(addprefix bench/d., $(dir_sizes))
	$(OCAMLCMD) scripts/run

interact: default
	$(OCAML) $(MLFLAGS) $(addsuffix .cma, $(LIBS))

pdf: paper/paper.pdf
ps: paper/paper.ps

mostlyclean:
	find . -name '*~' | xargs $(RM)
	$(RM) server.log 
	$(RM) -r metac/$(CM)

tex_junk = aux bbl blg log out
clean: mostlyclean
	$(RM) metac/metac.*-* server/*.cm?
	$(RM) scripts/run $(ml_files)
	$(RM) $(screens_png) $(screens_eps)
	$(RM) $(figs_tex) $(figs_eps) $(figs_pdf)
	$(RM) $(addprefix paper/paper., $(tex_junk) dvi ps 2ps)
	$(RM) -r paper/auto

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

# Image conversion
%.png: %.tiff
	$(CONVERT) $< -crop 0x0 $@
%.eps: %.png
	$(CONVERT) $< $@
%.pdf: %.eps
	$(EPSTOPDF) $<

# GNUplot
%.eps %.tex: %.gp
	cd $(dir $<) && $(GNUPLOT) $(notdir $<)

# LaTeX
%.pdf: %.tex
	cd $(dir $<) && TEXINPUTS=$(TEXINPUTS) $(TEXI2PDF) $(notdir $<)
%.dvi: %.tex
	cd $(dir $<) && TEXINPUTS=$(TEXINPUTS) $(TEXI2DVI) $(notdir $<)
%.ps: %.dvi
	cd $(dir $<) && \
	TEXINPUTS=$(TEXINPUTS) $(DVIPS) -o $(notdir $@) $(notdir $<)

###################################################################
###  Dependencies

# for server:
include Makefile.depend

server_modules := chunked timeStamp stringMap status request \
		  logFile server fileHandler codeHandler navBar
server_modules := $(addprefix server/, $(server_modules))
server_objects := $(addsuffix .cmo, $(server_modules))
server_sources := $(addsuffix .ml, $(server_modules))

server/server.cma: $(server_objects)
Makefile.depend: $(server_sources)
	$(OCAMLDEP) $(MLFLAGS) $^ >$@

# for metac:
metac_sources := $(addprefix metac/, $(shell tail +2 metac/metac.cm))
metac/metac.$(HEAP): $(metac_sources)

# for paper:
figures := $(addprefix bench/, static browse power)
figs_tex := $(addsuffix .tex, $(figures))
figs_eps := $(addsuffix .eps, $(figures))
figs_pdf := $(addsuffix .pdf, $(figures))

screens := $(addprefix paper/, confcal power127 server-dir gc)
screens_png := $(addsuffix .png, $(screens))
screens_eps := $(addsuffix .eps, $(screens))

TEXINPUTS = ../bench:../scripts:
tex_files = $(addprefix paper/, fonts.tex refs.bib)
paper/paper.pdf: $(tex_files) $(screens_png) $(figs_tex) $(figs_pdf)
paper/paper.dvi: $(tex_files) $(screens_eps) $(figs_tex) $(figs_eps)

###################################################################
###  Generating code map and run script 

plain_pages := /gc/Gc /Index /about/About /uname/Uname \
  /uptime/Uptime /http/Http /first/First /pi/Pi /perm/Perm \
  /perm2/Perm2 /perm3/Perm3 /count/Count
dir_pages := metac paper scripts server bench images

script_names := dir dirUn power powerUn \
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
	  echo "\"`dirname $$p`\", .! `basename $$p`.page;"  >>$@; \
	done
	for c in $(power_cases); do \
	  echo -n "\"/power$$c\", "                 >>$@; \
	  echo    ".! Power.page (Num.Int $$c);"    >>$@; \
	  echo -n "\"/powerun$$c\", "               >>$@; \
	  echo    ".! PowerUn.page (Num.Int $$c);"  >>$@; \
	done
	for z in $(static_sizes); do \
	  echo "\"/static$$z\", .! Static$$z.page;" >>$@; \
	done
	for d in $(dir_sizes); do \
	  echo "\"/browse$$d\", .! Dir.page \"\" \"bench/d.$$d\";" >>$@; \
	  echo "\"/unbrowse$$d\", .! DirUn.page \"bench/d.$$d\";" >>$@; \
	done
	echo "\"/browse\", .! Dir.page \"/browse\" \".\";" >>$@
	for d in $(dir_pages); do \
	  echo "\"/$$d/\", .! Dir.page \"/$$d/\" \"$$d\";" >>$@; \
	done
	echo '];;'          >>$@
	cat scripts/run_    >>$@

