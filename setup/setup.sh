#!/bin/bash

curdir=($PWD)

#Chaotic AUR Setup
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

sudo cp $curdir/pacman.conf /etc/pacman.conf

# Install packages
sudo pacman -Sy
cat $curdir/packages.txt | xargs sudo pacman -S --needed --noconfirm

cd ..
stow dotfiles
