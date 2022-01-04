SHELL := /bin/bash
CWD := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)

update:
	sudo apt update && sudo apt upgrade -y
	sudo flatpak update -y

repositories:
	# flatpak
	sudo add-apt-repository ppa:alexlarsson/flatpak

	# paper theme (icons and cursor)
	sudo add-apt-repository -u ppa:snwh/ppa

	# docker
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

	# syncthing
	curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
	echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

apt:
	sudo apt install xinit i3 kitty htop pcmanfm gthumb lxappearance flatpak arc-theme paper-icon-theme xdg-utils wireguard resolvconf blueman pavucontrol mpv virtualbox virtualbox-ext-pack openvpn ssh-askpass apt-transport-https ca-certificates curl gnupg lsb-release docker-ce docker-ce-cli containerd.io apt-transport-https syncthing keyboard-configuration console-setup v4l2loopback-dkms gphoto2 alsa-utils transmission-gtk -y

flatpak:
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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
	flatpak install flathub io.github.peazip.PeaZip -y
	sudo flatpak install flathub org.gtk.Gtk3theme.Arc-Dark -y

youtubedl:
	wget -O - https://yt-dl.org/downloads/latest/youtube-dl | sudo tee /usr/bin/youtube-dl >/dev/null
	sudo chmod a+x /usr/bin/youtube-dl

nvm:
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

configs:
	mkdir -p "$(HOME)/.config/i3"
	cp "$(CWD)/i3" "$(HOME)/.config/i3/config"
	sudo cp "$(CWD)/i3status" /etc/i3status.conf
	sudo cp "$(CWD)/xkb" /etc/default/keyboard
	sudo dpkg-reconfigure keyboard-configuration --frontend noninteractive
	sudo setupcon
	sudo systemctl enable "syncthing@$(USER).service"
	sudo systemctl start "syncthing@$(USER).service"
	sudo groupadd docker -f
	sudo usermod -aG docker $(USER)
	newgrp docker
	git config --global user.email "pharshmaster@gmail.com"
	git config --global user.name "border-radius"
	sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

postreboot:
	xdg-settings set default-web-browser org.mozilla.firefox.desktop

secrets:
	sudo cp "$(HOME)/secrets/wg/"*.conf /etc/wireguard
	mkdir -p "$(HOME)/.ssh"
	cp "$(HOME)/secrets/ssh/"* "$(HOME)/.ssh"
	chmod 600 "$(HOME)/.ssh/"*

battery:
	upower -i /org/freedesktop/UPower/devices/battery_BAT0

camera:
	sudo modprobe v4l2loopback
	sudo killall gvfs-gphoto2-volume-monitor || true
	gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video0

dockerstop:
	docker stop $(docker ps -a -q)

dockerclean:
	docker rm $(docker ps -a -q) 
	docker system prune -a
	docker system prune --volumes

everything: repositories update apt flatpak youtubedl nvm configs
