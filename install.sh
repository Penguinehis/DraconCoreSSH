#!/bin/bash
apt update
apt upgrade -y
apt install php-cli php-curl php-sqlite3 git -y
cake=$(uname -m)
if [ "$cake" = "x86_64" ]; then
curl -O https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvzf ioncube_loaders_lin_x86-64.tar.gz
rm ioncube_loaders_lin_x86-64.tar.gz
else
curl -O https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_aarch64.tar.gz
tar -xvzf ioncube_loaders_lin_aarch64.tar.gz
rm ioncube_loaders_lin_aarch64.tar.gz
fi
cd ioncube
php_ext_dir="$(command php -i | grep extension_dir 2>'/dev/null' \
| command head -n 1 \
| command cut --characters=31-38)"
php_version="$(command php --version 2>'/dev/null' \
| command head -n 1 \
| command cut --characters=5-7)"
cp ioncube_loader_lin_${php_version}.so /usr/lib/php/${php_ext_dir}
cd ..
rm -rf ioncube
cat > /etc/php/${php_version}/cli/conf.d/00-ioncube-loader.ini << EOF
zend_extension=ioncube_loader_lin_${php_version}.so
EOF



cd /opt/
rm -rf DragonCore
cd $HOME
git clone https://github.com/Penguinehis/DraconCoreSSH.git /opt/DragonCore
rm -rf /opt/DragonCore/aarch64
rm -rf /opt/DragonCore/x86_64
curl -s -L -o /opt/DragonCore/menu https://raw.githubusercontent.com/Penguinehis/DraconCoreSSH/main/$(uname -m)/menu
curl -s -L -o /opt/DragonCore/proxy https://raw.githubusercontent.com/Penguinehis/DraconCoreSSH/main/$(uname -m)/proxy
curl -s -L -o /opt/DragonCore/badvpn-udpgw https://raw.githubusercontent.com/Penguinehis/DraconCoreSSH/main/$(uname -m)/badvpn-udpgw
cd /opt/DragonCore
chmod +x *
cd $HOME
echo -n "/opt/DragonCore/menu" > /bin/menu
chmod +x /bin/menu
existing_cron=$(crontab -l 2>/dev/null | grep -F "*/5 * * * * find /run/user -maxdepth 1 -mindepth 1 -type d -exec mount -o remount,size=1M {} \;")
if [ -z "$existing_cron" ]; then
(crontab -l 2>/dev/null; echo "*/5 * * * * find /run/user -maxdepth 1 -mindepth 1 -type d -exec mount -o remount,size=1M {} \;") | crontab -
fi
if dpkg -s libssl1.1 &>/dev/null; then
echo "libssl1.1 is already installed."
else
echo "deb http://security.ubuntu.com/ubuntu focal-security main" | sudo tee /etc/apt/sources.list.d/focal-security.list
sudo apt-get update && sudo apt-get install -y libssl1.1
fi
