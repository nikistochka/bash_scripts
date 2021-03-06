#!/usr/bin/env bash

###############################################
# First run script for Ubuntu
###############################################

get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    jq -r ".tag_name"
}

sudo apt-get -y update
echo "Installing packages..."
sudo apt-get -y install git htop atop iotop zsh mc tmux jq

# Install docker
if ! docker --version > /dev/null; then
  sudo apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
  sudo apt-get -y update
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER
else
  echo "docker already installed"
fi

# Install docker-compose
if ! docker-compose --version > /dev/null; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "docker-compose already installed"
fi

# Install kubectl
if ! kubectl version --client > /dev/null; then
  sudo apt-get update && sudo apt-get install -y apt-transport-https
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubectl
else
  echo "kubectl already installed"
fi

# Install nvm
NVM_VERSION=$(get_latest_release nvm-sh/nvm)
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

# Add alias 'git lgb'
echo "Adding alias git lgb to ~/.gitconfig"
git config --global alias.lgb "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset%n' --abbrev-commit --date=relative --branches"

# Copy config files
cp config_files/.tmux.conf ~/.tmux.conf
mkdir -p ~/.vim/backup
cp config_files/.vimrc ~/.vimrc

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp config_files/robbyrussell.zsh-theme ~/.oh-my-zsh/custom/themes/robbyrussell.zsh-theme

# Changes to .zshrc
echo 'alias mc="mc -b"' | tee -a ~/.zshrc
echo 'alias k="kubectl"' | tee -a ~/.zshrc
echo 'unsetopt beep' | tee -a ~/.zshrc
echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' | tee -a ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm' | tee -a ~/.zshrc

source ~/.zshrc

# Install node LTS
nvm install --lts

# Install TLDR
npm install -g tldr

# Enable oh-my-zsh plugins
# by editing plugins=(git docker docker-compose)
