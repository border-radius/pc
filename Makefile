SHELL := /bin/bash
CWD := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)

update:
	sudo apt update && sudo apt upgrade -y

de:
	sudo add-apt-repository ppa:alexlarsson/flatpak
	sudo add-apt-repository -u ppa:snwh/ppa
	sudo apt install xinit i3 kitty htop pcmanfm gthumb lxappearance flatpak arc-theme paper-icon-theme -y
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	mkdir -p "$(HOME)/.config/i3"
	cp "$(CWD)/i3" "$(HOME)/.config/i3/config"
	sudo cp "$(CWD)/i3status" /etc/i3status.conf

software:
	sudo apt install virtualbox virtualbox-ext-pack -y
	flatpak install flathub org.mozilla.firefox
	flatpak install flathub org.chromium.Chromium
	flatpak install flathub org.telegram.desktop
	flatpak install flathub com.vscodium.codium
	flatpak install flathub org.gimp.GIMP
	flatpak install flathub us.zoom.Zoom
	flatpak install flathub org.libreoffice.LibreOffice
	flatpak install flathub io.freetubeapp.FreeTube
	flatpak install flathub org.electrum.electrum
	flatpak install flathub org.keepassxc.KeePassXC

syncthing:
	curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
	echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
	sudo apt-get install apt-transport-https syncthing -y
	sudo systemctl enable "syncthing@$(USER).service"
	sudo systemctl start "syncthing@$(USER).service"

keyboard:
	sudo apt install keyboard-configuration console-setup -y
	sudo cp "$(CWD)/keyboard" /etc/default/keyboard
	sudo dpkg-reconfigure keyboard-configuration --frontend noninteractive
	sudo setupcon

everything: update de keyboard software syncthing