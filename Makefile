# ros-archive-keyring/Makefile

export DH_VERBOSE = 1

include /usr/share/dpkg/default.mk

# Packages are listed in the order they appear in debian/control.
# https://manpages.debian.org/dh_listpackages
PKGNAME := $(word 1, $(shell dh_listpackages))

GPG_OPTIONS := --verbose --no-options --no-default-keyring --no-auto-check-trustdb --trustdb-name ./trustdb.gpg

URI := http://packages.ros.org/ros/ubuntu/

SUITE := $(shell sh -c '. /etc/os-release && echo $$VERSION_CODENAME')

.PHONY: all
all: $(PKGNAME).gpg

$(PKGNAME).gpg: ros.asc
	GNUPGHOME="$$(mktemp -dt GNUPGHOME.XXXXXX)" \
		gpg $(GPG_OPTIONS) --import --keyring ./$@ ros.asc

.PHONY: clean
clean:
	rm -vf trustdb.gpg $(PKGNAME).gpg $(PKGNAME).gpg~

# https://wiki.debian.org/DebianRepository/UseThirdParty
.PHONY: install
install: $(PKGNAME).gpg
	mkdir -vp $(DESTDIR)/usr/share/keyrings/
	cp -va $^ $(DESTDIR)/usr/share/keyrings/$(PKGNAME).gpg
	mkdir -vp $(DESTDIR)/etc/apt/sources.list.d/
	{ true \
	&& echo "deb     [signed-by=/usr/share/keyrings/$(PKGNAME).gpg] $(URI) $(SUITE) main" \
	&& echo "deb-src [signed-by=/usr/share/keyrings/$(PKGNAME).gpg] $(URI) $(SUITE) main" \
	; } >$(DESTDIR)/etc/apt/sources.list.d/ros.list
	{ true \
	&& echo "Types: deb src" \
	&& echo "URIs: $(URI)" \
	&& echo "Suites: $(SUITE)" \
	&& echo "Components: main" \
	&& echo "Signed-By: /usr/share/keyrings/$(PKGNAME).gpg" \
	; } >$(DESTDIR)/etc/apt/sources.list.d/ros.sources
	mkdir -vp $(DESTDIR)/etc/apt/preferences.d/
	{ true \
	&& echo "Package: $(PKGNAME)" \
	&& echo "Pin: origin packages.ros.org" \
	&& echo "Pin-Priority: 100" \
	; } >$(DESTDIR)/etc/apt/preferences.d/ros.pref
