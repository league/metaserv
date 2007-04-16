include ../Makefile.rules

default: metac.$(heap)

metac.$(heap): sources.cm $(shell tail +2 sources.cm)
	echo 'SMLofNJ.exportFn("metac", Main.main);' | $(sml) sources.cm

clean:
	rm -rf $(junk) metac.*-* .cm

reallyclean: clean
	rm -f meta.grm.sig meta.grm.sml meta.lex.sml
