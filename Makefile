# ros-archive-keyring/Makefile

GPG_OPTIONS := --verbose --no-options --no-default-keyring --no-auto-check-trustdb --trustdb-name ./trustdb.gpg

URI := http://packages.ros.org/ros/ubuntu/

SUITE := $(shell sh -c '. /etc/os-release && echo $$VERSION_CODENAME')

.PHONY: all
all: ros-archive-keyring.gpg

ros-archive-keyring.gpg: ros.asc
	gpg $(GPG_OPTIONS) --import --keyring ./$@ ros.asc

.PHONY: clean
clean:
	rm -vf trustdb.gpg ros-archive-keyring.gpg ros-archive-keyring.gpg~

# https://wiki.debian.org/DebianRepository/UseThirdParty
.PHONY: install
install: ros-archive-keyring.gpg
	mkdir -vp $(DESTDIR)/usr/share/keyrings/
	cp -va $^ $(DESTDIR)/usr/share/keyrings/ros-archive-keyring.gpg
	mkdir -vp $(DESTDIR)/etc/apt/sources.list.d/
	{ true \
	&& echo "deb     [signed-by=$(DESTDIR)/usr/share/keyrings/ros-archive-keyring.gpg] $(URI) $(SUITE) main" \
	&& echo "deb-src [signed-by=$(DESTDIR)/usr/share/keyrings/ros-archive-keyring.gpg] $(URI) $(SUITE) main" \
	; } >$(DESTDIR)/etc/apt/sources.list.d/ros.list
	{ true \
	&& echo "Types: deb src" \
	&& echo "URIs: $(URI)" \
	&& echo "Suites: $(SUITE)" \
	&& echo "Components: main" \
	&& echo "Signed-By: $(DESTDIR)/usr/share/keyrings/ros-archive-keyring.gpg" \
	; } >$(DESTDIR)/etc/apt/sources.list.d/ros.sources
	mkdir -vp $(DESTDIR)/etc/apt/preferences.d/
	{ true \
	&& echo "Package: ros-archive-keyring" \
	&& echo "Pin: origin packages.ros.org" \
	&& echo "Pin-Priority: 100" \
	; } >$(DESTDIR)/etc/apt/preferences.d/ros.pref
