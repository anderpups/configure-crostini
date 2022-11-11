#!/bin/bash
## Doesn't work yet but
# use as a reference
set -e
# setup github cli repo
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
fi

## vscode
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

## update upgrade
sudo apt update
sudo apt -y dist-upgrade

# install apt packages
sudo apt -y install zsh python3-pip fonts-powerline tldr adapta-gtk-theme dconf-editor gh

git config --global user.email "anderpups@gmail.com"
git config --global user.name "Brad Anderson"
git config --global pull.rebase true
git config --global init.defaultBranch main

# make sure we have the pip binary path
if ! grep -qF "export PATH=$PATH:~/.local/bin" ~/.zshrc; then
  echo "export PATH=$PATH:~/.local/bin" >> ~/.zshrc
  source ~/.zshrc
fi
# install pip packages
pip3 install --user ansible molecule
# Pull down latest tldr entries
tldr -u

# install oh-my-zsh
sudo -E chsh --shell /usr/bin/zsh $USER
if [ -z /home/$USER/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
#Set the zsh theme
sed --in-place 's/ZSH_THEME=.*$/ZSH_THEME=agnoster/' ~/.zshrc

# cp over gtk config for dark theme
cp ./files/.gtkrc-2.0 ~/.gtkrc-2.0
# cp over sommelier config to make banner dark mode
cp -rvf ./files/systemd  ~/.config/
# set dark theme for gnome
gsettings set org.gnome.desktop.interface gtk-theme "Adapta-Nokto"

# set some settings for vs-code
cp -f ./files/vscode-settings.json ~/.config/Code/User/settings.json
