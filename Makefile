NAME=textql
VERSION=2.0.3
EPOCH=1
ITERATION=1
PREFIX=/usr/local
LICENSE=MIT
VENDOR="Paul Bergeron"
MAINTAINER="Ryan Parman"
DESCRIPTION="TextQL allows you to easily execute SQL against structured text like CSV or TSV."
URL=https://github.com/dinedal/textql
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

#-------------------------------------------------------------------------------

all: info clean install-deps compile install-tmp package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "EPOCH:       $(EPOCH)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* textql*

#-------------------------------------------------------------------------------

.PHONY: install-deps
install-deps:
	yum install -y \
		golang \
		make \
	;

#-------------------------------------------------------------------------------

.PHONY: compile
compile:
	export GOPATH=/tmp/gocode && mkdir -p $$GOPATH;
	go get -u -d github.com/dinedal/textql;
	cd $$GOPATH/src/github.com/dinedal/textql && \
		git checkout $(VERSION) && \
		make \
	;

#-------------------------------------------------------------------------------

.PHONY: install-tmp
install-tmp:
	mkdir -p /tmp/installdir-$(NAME)-$(VERSION)/usr/local/bin;
	cd $$GOPATH/src/github.com/dinedal/textql && \
		cp ./build/textql /tmp/installdir-$(NAME)-$(VERSION)/usr/local/bin/textql;

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-f \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-C /tmp/installdir-$(NAME)-$(VERSION) \
		-m $(MAINTAINER) \
		--epoch $(EPOCH) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix / \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrdir 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-changelog CHANGELOG.txt \
		--rpm-dist el$(RHEL) \
		--rpm-auto-add-directories \
		usr/local/bin \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/
