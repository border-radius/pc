SHELL := /bin/bash
CWD := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)

update:
	sudo apt update && sudo apt upgrade -y

de:
	sudo add-apt-repository ppa:alexlarsson/flatpak
	sudo add-apt-repository -u ppa:snwh/ppa
	sudo apt install xinit i3 kitty htop pcmanfm gthumb lxappearance flatpak arc-theme paper-icon-theme xdg-utils wireguard resolvconf blueman pavucontrol mpv -y
	wget -O - https://yt-dl.org/downloads/latest/youtube-dl | sudo tee /usr/bin/youtube-dl >/dev/null
	sudo chmod a+x /usr/bin/youtube-dl
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	mkdir -p "$(HOME)/.config/i3"
	cp "$(CWD)/i3" "$(HOME)/.config/i3/config"
	sudo cp "$(CWD)/i3status" /etc/i3status.conf

software:
	sudo apt install virtualbox virtualbox-ext-pack openvpn ssh-askpass -y
	flatpak install flathub org.mozilla.firefox -y
	flatpak install flathub org.chromium.Chromium -y
	flatpak install flathub org.telegram.desktop -y
	flatpak install flathub com.vscodium.codium -y
	flatpak install flathub org.gimp.GIMP -y
	flatpak install flathub us.zoom.Zoom -y
	flatpak install flathub org.libreoffice.LibreOffice -y
	flatpak install flathub io.freetubeapp.FreeTube -y
	flatpak install flathub org.electrum.electrum -y
	flatpak install flathub org.keepassxc.KeePassXC -y
	flatpak install flathub com.github.micahflee.torbrowser-launcher -y

docker:
	sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
	sudo apt-get install docker-ce docker-ce-cli containerd.io -y
	sudo groupadd docker -f
	sudo usermod -aG docker $(USER)
	newgrp docker

nvm:
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

syncthing:
	curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
	echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	sudo apt-get install apt-transport-https syncthing -y
	sudo systemctl enable "syncthing@$(USER).service"
	sudo systemctl start "syncthing@$(USER).service"

keyboard:
	sudo apt install keyboard-configuration console-setup -y
	sudo cp "$(CWD)/xkb" /etc/default/keyboard
	sudo dpkg-reconfigure keyboard-configuration --frontend noninteractive
	sudo setupcon

secrets:
	sudo cp "$(HOME)/secrets/wg/"*.conf /etc/wireguard
	mkdir -p "$(HOME)/.ssh"
	cp "$(HOME)/secrets/ssh/"* "$(HOME)/.ssh"
	chmod 600 "$(HOME)/.ssh/"*

defaults:
	xdg-settings set default-web-browser org.mozilla.firefox.desktop

battery:
	upower -i /org/freedesktop/UPower/devices/battery_BAT0

everything: update de keyboard software nvm syncthing
