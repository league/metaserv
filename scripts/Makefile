include ../Makefile.rules

scripts= power gc $(addprefix static, $(sizes))
#dir
mlfiles=$(addsuffix .ml, $(scripts))

default: run

run: all run_
	cat $^ >$@

all: $(mlfiles) Makefile
	echo -n >$@
	for x in $(mlfiles); do \
	  echo '#use "scripts/'$$x'";;' >>$@; \
	done

%.ml: %.meta
	$(sml) @SMLload=../metac/metac $^

.PRECIOUS: $(addsuffix .meta, $(scripts))

static%.meta:
	mimencode </dev/urandom | dd bs=1K count=$* >$@

clean:
	rm -f $(junk) all run $(mlfiles)

reallyclean: clean
	rm -f static*.meta

