#!/bin/bash
set -e

echo "Installing packages..."
sudo apt update && sudo apt install -y git vim curl build-essential

echo "Linking vimrc..."
ln -sf ~/dotfiles/.vimrc ~/.vimrc

echo "Installing Betty..."
rm -rf /tmp/Betty
git clone https://github.com/alx-tools/Betty.git /tmp/Betty
cd /tmp/Betty
sudo ./install.sh
sudo cp betty.sh /usr/local/bin/betty
sudo chmod +x /usr/local/bin/betty

echo "Installing vim plugins..."
vim +PlugInstall +qall

echo "Done."
