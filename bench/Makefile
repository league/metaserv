include ../Makefile.rules
TEX=latex

default: $(addprefix d., $(dir-sizes))

clean:
	rm -rf $(junk) auto
	rm -f $(addprefix figs., $(texjunk)) figs.pdf
	rm -f $(addprefix testpage., $(texjunk))
	rm -f $(figs_tex) $(figs_eps) $(figs_pdf)

reallyclean: clean
	rm -rf r.* d.?? 

depend:

methods=camlfile camlcode apache php
all: $(addprefix r.static., $(methods)) r.power r.powerun r.browse r.unbrowse

r.static.%:
	echo >$@
	for n in $(static-sizes); do \
	  ./static-overhead $* $$n 2>&1 \
	    | tee -a $@; \
	done

r.pow%:
	echo >$@
	for z in $(power-cases); do \
	  ./test-url pow$*`dirname $$z` 2>&1 \
	    | tee -a $@; \
	done

d.%:
	./make-sim-dir $*

r.%owse: 
	echo >$@
	for d in $(dir-sizes); do \
	  ./test-url $*owse$$d 2>&1 \
	    | tee -a $@; \
	done

figs: figs.dvi

figs.dvi: figs.tex $(addsuffix .eps, $(figs))

figs.pdf: figs.tex $(addsuffix .pdf, $(figs))
	pdflatex $<

%.ps: %.dvi
	dvips $<

%.eps %.tex: %.gp
	gnuplot $<

%.pdf: %.eps
	epstopdf $<

testpage.pdf: testpage.tex test.pdf
	pdflatex $<
