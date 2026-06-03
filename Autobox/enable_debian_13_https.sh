# This script changes the code-server config file to allow access via 8080


# This script changes the code-server config file to allow access via 8080



sudo apt -y install python3-pip
sudo apt -y install ufw
sudo apt -y install python3.13-venv

mkdir ~/pyenv/
python3 -m env ~/pyenv/default
source ~/pyevn/default/bin/activate
pip3 install ansible<12 # We don't want 12 until the Ansible Core 2.19 issue has been resolved
pip3 install ansible-lint

echo "Installing other utilities"

sudo apt -y install argon2
sudo apt -y install git
sudo apt -y install vim
sudo apt -y install wget
sudo apt -y install curl
sudo apt -y install btop

echo "Installing and enabling code server"

curl -fsSL https://code-server.dev/install.sh | sh


sudo systemctl enable --now code-server@$USER

sleep 3


if [ -e ~/.config/code-server/config.yaml ]
then
    echo "Code-server installation detected, proceeding"
else
    echo "config.yaml file not found, please install and enable code-server"
    exit
fi


echo -e "\e[31mWhat password would you like to set for access to code-server?\e[0m"

read -s password

cp ~/.config/code-server/config.yaml ~/.config/code-server/config.yaml.orig
echo "auth: password" > ~/.config/code-server/config.yaml
echo "bind-addr: 0.0.0.0:8080" >> ~/.config/code-server/config.yaml
echo "cert: true" >> ~/.config/code-server/config.yaml

salt=$(openssl rand -base64 12)

hashpassword=$(echo -n $password | argon2 $salt -e)

echo "hashed-password: $hashpassword" >> ~/.config/code-server/config.yaml
echo "Now restarting code-server to activate new settings. The config file can be edited at ~/config/code-server/config.yaml"
sudo systemctl restart code-server@$USER

echo "Configuring the firewall to allow port 8080"

sudo apt-get -y install ufw
sudo ufw allow 8080


echo "Downloading TLS setup script to ~/.local/bin/"
mkdir ~/.local/bin
curl https://raw.githubusercontent.com/tonybourke/Project-NERD/refs/heads/main/Autobox/setup_tls.sh > ~/.local/bin/setup_tls.sh
chmod +x ~/.local/bin/setup_tls.sh
echo "Run command: setup_tls.sh [IP], i.e. 'sh /usr/local/bin/setup_tls.sh 192.168.1.100'"

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


sudo systemctl enable docker
sudo systemctl start docker

bash -c "$(curl -sL https://get.containerlab.dev)"
