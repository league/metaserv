include ../Makefile.rules
texenv= TEXINPUTS=.:../bench:../scripts::
texdvi= $(texenv) texi2dvi
texpdf= $(texenv) texi2pdf
dvips = $(texenv) dvips

images=power127 gc server-dir confcal
images_eps=$(addsuffix .eps, $(images))
images_png=$(addsuffix .png, $(images))

default:

all: paper.pdf paper.ps

depend:

clean:
	rm -f *~ $(addprefix paper., $(texjunk))
	rm -f $(figs_tex) $(figs_eps) $(figs_pdf) $(images_eps) $(images_png)

reallyclean: clean
	rm -rf paper.pdf auto

%.dvi: %.tex
	$(texdvi) $<

%.ps: %.dvi
	$(dvips) -o $@ $<

%.eps: %.png
	convert $< $@

%.png: %.tiff
	convert $< -crop 0x0 $@

texinputs=paper.tex fonts.tex refs.bib $(addprefix ../bench/, $(figs_tex))
paper.dvi: $(texinputs) $(images_eps) $(addprefix ../bench/, $(figs_eps))

paper.pdf: $(texinputs) $(images_png) $(addprefix ../bench/, $(figs_pdf))
	$(texpdf) paper.tex

../bench/%.tex:
	make -C ../bench figs.dvi

../bench/%.eps:
	make -C ../bench figs.dvi

../bench/%.pdf:
	make -C ../bench figs.pdf

# $(figs_tex) $(figs_eps) $(figs_pdf): ../bench/figs.pdf
# 	ln -sf ../bench/$@

