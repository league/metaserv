sizes=01 02 04 08 16 32 64
scripts=dir power gc $(addprefix static, $(sizes))

default: run

run: all run_
	cat $^ >$@

all: $(addsuffix .ml, $(scripts))
	echo -n >$@
	for x in $^; do \
	  echo '#use "scripts/'$$x'";;' >>$@; \
	done

%.ml: %.meta
	$(sml) @SMLload=../metac/metac $^

.PRECIOUS: $(addsuffix .meta, $(scripts))

static%.meta:
	mimencode </dev/urandom | dd bs=1K count=$* >$@

clean:
	rm -f $(junk) all run $(addsuffix .ml, $(scripts))

reallyclean: clean
	rm -f static*.meta

include ../Makefile.rules
