include ../Makefile.rules

plain-pages=/gc/Gc /Index /about/About /uname/Uname \
  /uptime/Uptime /http/Http /first/First /pi/Pi /perm/Perm \
  /perm2/Perm2 /perm3/Perm3 /count/Count
scripts= dir dirUn power powerUn $(addprefix static, $(static-sizes)) \
	 $(notdir $(shell echo $(plain-pages) | tr '[A-Z]' '[a-z]'))
mlfiles=$(addsuffix .ml, $(scripts))

default: run

run: all map run_
	cat all                   >$@
	echo "let code_list = [" >>$@
	cat map                  >>$@
	echo "];;"               >>$@
	cat run_                 >>$@

all: $(mlfiles) Makefile
	echo '#use "scripts/navspec.ml";;' >$@
	for x in $(mlfiles); do \
	  echo '#use "scripts/'$$x'";;' >>$@; \
	done

dir-pages=metac paper scripts server bench images
map: Makefile 
	echo -n >map
	for p in $(plain-pages); do \
	  echo "\"`dirname $$p`\", .! `basename $$p`.page;"  >>map; \
	done
	for c in $(power-cases); do \
	  echo -n "\"/power$$c\", "                 >>map; \
	  echo    ".! Power.page (Num.Int $$c);"    >>map; \
	  echo -n "\"/powerun$$c\", "               >>map; \
	  echo    ".! PowerUn.page (Num.Int $$c);"  >>map; \
	done
	for z in $(static-sizes); do \
	  echo "\"/static$$z\", .! Static$$z.page;" >>map; \
	done
	for d in $(dir-sizes); do \
	  echo "\"/browse$$d\", .! Dir.page \"\" \"bench/d.$$d\";" >>map; \
	  echo "\"/unbrowse$$d\", .! DirUn.page \"bench/d.$$d\";" >>map; \
	done
	echo "\"/browse\", .! Dir.page \"/browse\" \".\";" >>map
	for d in $(dir-pages); do \
	  echo "\"/$$d/\", .! Dir.page \"/$$d/\" \"$$d\";" >>map; \
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

