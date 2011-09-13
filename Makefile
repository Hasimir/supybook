PARAMS=-a toc -a toclevels=3 -a date=$(shell date +%Y-%m-%d) -a numbered -d book
ifdef VERSION
REVISION=$(VERSION)
endif
ifdef REVISION
PARAMS+=-a revision=$(REVISION)
else
PARAMS+=-a revision=$(shell git describe)$(shell git diff-index HEAD |grep '' > /dev/null && echo '+dirty')
endif

# local optional makefile for deploying
# WEBDIR=/path/to/supybook.fealdia.org/
WEBDIR=
-include Makefile.local

all: html deploy

html: index.html

pdf: index.pdf

release: clean html pdf
ifndef VERSION
	@echo "Usage: make release VERSION=x"
	@false
else
	tar --owner=0 --group=0 --transform 's!^!supybook-$(VERSION)/!' -zcf supybook-$(VERSION).tar.gz index.txt index.html Makefile index.pdf
endif

%.html: %.txt
	asciidoc $(PARAMS) $<

%.pdf: %.txt
	a2x $(PARAMS) -f pdf $<

clean:
	@$(RM) index.html index.pdf

deploy: html
ifeq ($(WEBDIR),)
	@echo "No Makefile.local, skipping deploy"
else
	@echo "Deploying to $(WEBDIR)"
	cp index.html $(WEBDIR)/devel/index.html
endif

.PHONY: all deploy pdf release release-tar
