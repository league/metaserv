subdirs=server metac scripts paper
mlflags=-I server

default:
	for d in $(subdirs); do $(MAKE) -C $$d default; done

interact: default
	$(ocaml) 

run: default
	$(ocaml) scripts/run

depend:
	for d in $(subdirs); do $(MAKE) -C $$d depend; done

clean:
	rm -f $(junk) server.log
	for d in $(subdirs); do $(MAKE) -C $$d clean; done

reallyclean: clean
	for d in $(subdirs); do $(MAKE) -C $$d reallyclean; done

method=camlcode
static-bench:
	for n in 01 02 04; do \
	  bench/static-overhead $(method) $$n 2>&1 \
	    | tee bench/static.$(method).$$n; \
	done

include Makefile.rules
