#!/bin/ruby

# network proxy
httpProxy = ENV['http_proxy']
httpProxy ||= ''
httpsProxy = ENV['https_proxy']
httpsProxy ||= ''
ftpProxy = ENV['ftp_proxy']
ftpProxy ||= ''
noProxy = ENV['no_proxy']
noProxy ||= ''

Vagrant.configure(2) do |config|

  # distribution
  config.vm.box = "debian/jessie64"

  # hostname
  config.vm.hostname = "node0.nttdata.com"

  config.vm.network "private_network", ip: "192.168.33.20"

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "512"
     vb.name = "zsh-setup-test"
  end

  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    s.inline = "sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /home/vagrant/.profile"
  end

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = httpProxy
    config.proxy.https    = httpsProxy
    config.proxy.no_proxy = noProxy
  end

  config.vm.provision "shell", name: "setup-proxy", privileged: false, args: [httpProxy, httpsProxy, ftpProxy, noProxy], inline: <<-SHELL
    export http_proxy="$1"
    export https_proxy="$2"
    export ftp_proxy="$3"
    export no_proxy="$4"
    cd /vagrant
    make proxy
  SHELL

  config.vm.provision "shell", name: "update-apt", privileged: true, inline: <<-SHELL
    aptitude update
    aptitude upgrade -y
    aptitude install -y apt-transport-https ca-certificates screen emacs-nox htop
  SHELL

  config.vm.provision "shell", name: "setup-time", privileged: true, inline: <<-SHELL
    timedatectl set-timezone Europe/Berlin
  SHELL
  
  config.vm.provision "shell", name: "make-all", privileged: false, args: [httpProxy, httpsProxy, ftpProxy, noProxy], inline: <<-SHELL
    export http_proxy="$1"
    export https_proxy="$2"
    export ftp_proxy="#3"
    export no_proxy="$4"
    cd /vagrant
    make all
  SHELL

end
