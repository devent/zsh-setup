# Copyright 2016 Erwin Müller, erwin.mueller@deventm.org
#
# Licensed to the Apache Software Foundation (ASF) under one or more contributor
# license agreements. See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  The ASF licenses this
# file to you under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# 06/06/2016 - 1.1
# add @screenrc@ support;
# 25/05/2016 - 1.0
# first release version;
#
# set the zsh plugins to load, for example ``make PLUGINS="git docker"''.
PLUGINS ?=
# set the oh-my-zsh theme to load.
THEME ?= gentoo
# set the remote editor.
REMOTE_EDITOR ?= emacs
# set the local editor.
LOCAL_EDITOR ?= emacs
# set the working directory, for example ``make WORK=/tmp'' for test.
WORK ?= $(shell realpath ~)
# allows passing of proxy variables to sudo.
SUDO_PROXY := /etc/sudoers.d/08proxy
# apt proxy.
APT_PROXY := /etc/apt/apt.conf.d/08proxy
# proxy environmen variables.
PROXY := /etc/profile.d/proxy.sh
# shell unspecific settings, for example alias, paths, etc.
USER_RC := $(WORK)/.user_rc
# zsh specific settings.
USER_ZSHRC := $(WORK)/.user_zshrc
# zsh shell.
ZSH := /bin/zsh
# zsh configuration file, will be overriden by this script.
ZSHRC := $(WORK)/.zshrc
# screen tool.
SCREEN := /usr/bin/screen
# screen configuration file, will be overriden by this script.
SCREEN_RC := $(WORK)/.screenrc
# oh-my-zsh.
OHMYZSH := /opt/oh-my-zsh
# autojump.
AUTOJUMP := /usr/share/autojump/autojump.zsh
# bash-completion.
BASH_COMPLETION := /etc/bash_completion.d
# applications.
APT := $(shell which aptitude)
SUDO := $(shell which sudo)
# the current user.
USER := $(shell whoami)
# default goal is "all".
.DEFAULT_GOAL := all

include docker_make_utils/Makefile.help

.PHONY: all test proxy setup clean screen zshrcuser geometry-theme

all: setup $(APT) $(SUDO) $(APT_PROXY) $(PROXY) $(ZSH) $(ZSHRC) $(OHMYZSH) $(AUTOJUMP) $(BASH_COMPLETION) screen $(USER_RC) $(USER_ZSHRC) zshrcuser ##@default Setups everything.

clean: ##@targets Removes the generated files except .user_rc and .user_zsh.
	$(SUDO) rm $(SUDO_PROXY); true
	$(SUDO) rm $(APT_PROXY); true
	$(SUDO) rm $(PROXY); true
	rm $(ZSHRC); true
	rm $(SCREEN_RC); true

test: setup ##@targets Creates a virtual machine and tests the setup.
	if [ -z "`vagrant plugin list|grep 'vagrant-vbguest (0.11.0)'`" ]; then \
	vagrant plugin install vagrant-vbguest; \
	fi
	if [ -z "`vagrant plugin list|grep 'vagrant-proxyconf (1.5.2)'`" ]; then \
	vagrant plugin install vagrant-proxyconf; \
	fi
	vagrant up
	vagrant ssh -c "cd /vagrant; make all"
	vagrant ssh
	vagrant destroy
	

proxy: setup $(SUDO) $(APT_PROXY) $(PROXY)
	
setup:
	chmod +x *.sh

screen: $(SCREEN) $(SCREEN_RC)
	
$(APT):
	
$(SUDO): $(SUDO_PROXY)

$(SUDO_PROXY):
	$(SUDO) bash -c "./proxy_sudoers_template.sh > $(SUDO_PROXY)"

$(ZSH):
	$(SUDO) $(APT) -y install zsh
	
$(AUTOJUMP):
	$(SUDO) $(APT) -y install autojump
	
$(BASH_COMPLETION):
	$(SUDO) $(APT) -y install bash-completion
	
$(OHMYZSH):
	$(SUDO) aptitude -y install wget unzip
	cd /tmp; \
	wget https://github.com/robbyrussell/oh-my-zsh/archive/master.zip -O oh-my-zsh.zip; \
	$(SUDO) unzip -q oh-my-zsh.zip; \
	$(SUDO) mv /tmp/oh-my-zsh-master /opt/oh-my-zsh/
	$(SUDO) chmod o+w  /opt/oh-my-zsh/cache
	
$(SCREEN):
	$(SUDO) $(APT) -y install screen
	
$(ZSHRC):
	export OHMYZSH=$(OHMYZSH); \
	export THEME=$(THEME); \
	export REMOTE_EDITOR=$(REMOTE_EDITOR); \
	export LOCAL_EDITOR=$(LOCAL_EDITOR); \
	export AUTOJUMP=$(AUTOJUMP); \
	export PROXY=$(PROXY); \
	export USER_RC=$(USER_RC); \
	export USER_ZSHRC=$(USER_ZSHRC); \
	[ -f "$(ZSHRC)" ] && cp "$(ZSHRC)" "$(ZSHRC).backup"; true; \
	./zsh_template.sh > $(ZSHRC)

$(PROXY):
	$(SUDO) bash -c "./proxy_template.sh > $(PROXY)"
	
$(APT_PROXY):
	$(SUDO) rm $(APT_PROXY); true
	$(SUDO) bash -c "./apt_proxy_template.sh > $(APT_PROXY)"

$(USER_RC):
	touch $(USER_RC)

$(USER_ZSHRC):
	touch $(USER_ZSHRC)

$(SCREEN_RC):
	[ -f "$(SCREEN_RC)" ] && cp "$(SCREEN_RC)" "$(SCREEN_RC).backup"; true; \
	./screenrc_template.sh > $(SCREEN_RC)
	
zshrcuser:
	$(SUDO) usermod -s /bin/zsh $(USER)

geometry-theme: $(OHMYZSH)/custom/themes ##@themes Setups the geometry oh-my-zsh theme.
	$(SUDO) aptitude -y install sed wget unzip
	cd /tmp; \
	wget https://github.com/frmendes/geometry/archive/master.zip -O geometry.zip; \
	$(SUDO) unzip geometry.zip; \
	$(SUDO) mv /tmp/geometry-master/geometry.zsh $(OHMYZSH)/custom/themes/geometry.zsh-theme; \
	$(SUDO) rm -rf /tmp/geometry-master; \
	$(SUDO) sed -i 's/ZSH_THEME=".*"/ZSH_THEME="geometry"/g' $(ZSHRC)

$(OHMYZSH)/custom/themes:
	$(SUDO) mkdir -p $(OHMYZSH)/custom/themes
