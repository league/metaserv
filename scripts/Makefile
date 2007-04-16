include ../Makefile.rules

scripts= dir dirUn power powerUn gc $(addprefix static, $(static-sizes))
mlfiles=$(addsuffix .ml, $(scripts))

default: run

run: all map run_
	cat all                   >$@
	echo "let code_list = [" >>$@
	cat map                  >>$@
	echo "];;"               >>$@
	cat run_                 >>$@

all: $(mlfiles) Makefile
	echo -n >$@
	for x in $(mlfiles); do \
	  echo '#use "scripts/'$$x'";;' >>$@; \
	done

plain-pages=gc/Gc 
map: Makefile 
	echo -n >map
	for p in $(plain-pages); do \
	  echo "\"/`dirname $$p`\", .! `basename $$p`.page;"  >>map; \
	done
	for c in $(power-cases); do \
	  echo -n "\"/power`dirname $$c`\", "                 >>map; \
	  echo    ".! Power.page (Num.Int `basename $$c`);"   >>map; \
	  echo -n "\"/powerun`dirname $$c`\", "               >>map; \
	  echo    ".! PowerUn.page (Num.Int `basename $$c`);" >>map; \
	done
	for z in $(static-sizes); do \
	  echo "\"/static$$z\", .! Static$$z.page;" >>map; \
	done
	for d in $(dir-sizes); do \
	  echo "\"/browse$$d\", .! Dir.page \"bench/d.$$d\";" >>map; \
	  echo "\"/unbrowse$$d\", .! DirUn.page \"bench/d.$$d\";" >>map; \
	done

%.ml: %.meta
	$(sml) @SMLload=../metac/metac $^

.PRECIOUS: $(addsuffix .meta, $(scripts))

static%.meta:
	mimencode </dev/urandom | dd bs=1K count=$* >$@

clean:
	rm -f $(junk) all run map $(mlfiles)

reallyclean: clean
	rm -f static*.meta

