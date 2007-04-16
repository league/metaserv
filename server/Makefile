include ../Makefile.rules
objects=chunked timeStamp stringMap status request logFile server fileHandler 

default: server.cma

server.cma: $(addsuffix .cmo, $(objects))

depend: $(addsuffix .ml*, $(objects))
	$(metadir)/ocamldep $^ > Makefile.depend

clean:
	rm -f $(junk)

reallyclean: clean

include Makefile.depend
