.DEFAULT_GOAL := all
WORK ?= $(shell realpath ~)
SUDO_PROXY := /etc/sudoers.d/08proxy
APT_PROXY := /etc/apt/apt.conf.d/08proxy
PROXY := /etc/profile.d/proxy.sh
USER_RC := $(WORK)/.user_rc
USER_ZSHRC := $(WORK)/.user_zshrc
ZSH := /bin/zsh
ZSHRC := $(WORK)/.zshrc
OHMYZSH := /opt/oh-my-zsh
AUTOJUMP := /usr/share/autojump/autojump.zsh
BASH_COMPLETION := /etc/bash_completion.d
PLUGINS ?=
THEME ?= gentoo
REMOTE_EDITOR ?= emacs
LOCAL_EDITOR ?= emacs
APT := $(shell which aptitude)
SUDO := $(shell which sudo)
USER := $(shell whoami)

.PHONY: test proxy all setup clean zshrcuser geometry-theme

test: setup
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
	
all: setup $(APT) $(SUDO) $(APT_PROXY) $(PROXY) $(ZSH) $(ZSHRC) $(OHMYZSH) $(AUTOJUMP) $(BASH_COMPLETION) $(USER_RC) $(USER_ZSHRC) zshrcuser

setup:
	chmod +x *.sh

clean:
	$(SUDO) rm $(SUDO_PROXY)
	$(SUDO) rm $(APT_PROXY)
	$(SUDO) rm $(PROXY)
	rm $(ZSHRC)
	
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
	wget -q https://github.com/robbyrussell/oh-my-zsh/archive/master.zip -O oh-my-zsh.zip; \
	$(SUDO) unzip -q oh-my-zsh.zip; \
	$(SUDO) mv /tmp/oh-my-zsh-master /opt/oh-my-zsh/
	
$(ZSHRC):
	export OHMYZSH=$(OHMYZSH); \
	export THEME=$(THEME); \
	export REMOTE_EDITOR=$(REMOTE_EDITOR); \
	export LOCAL_EDITOR=$(LOCAL_EDITOR); \
	export AUTOJUMP=$(AUTOJUMP); \
	export PROXY=$(PROXY); \
	export USER_RC=$(USER_RC); \
	export USER_ZSHRC=$(USER_ZSHRC); \
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
	
zshrcuser:
	$(SUDO) usermod -s /bin/zsh $(USER)

geometry-theme: $(OHMYZSH)/custom/themes
	$(SUDO) aptitude -y install sed wget unzip
	cd /tmp; \
	wget https://github.com/frmendes/geometry/archive/master.zip -O geometry.zip; \
	$(SUDO) unzip geometry.zip; \
	$(SUDO) mv /tmp/geometry-master/geometry.zsh $(OHMYZSH)/custom/themes/geometry.zsh-theme; \
	$(SUDO) rm -rf /tmp/geometry-master; \
	$(SUDO) sed -i 's/ZSH_THEME=".*"/ZSH_THEME="geometry"/g' $(ZSHRC)

$(OHMYZSH)/custom/themes:
	$(SUDO) mkdir -p $(OHMYZSH)/custom/themes
