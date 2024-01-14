#!/bin/bash
apt install php-cli php-curl php-sqlite3 git -y
curl -O https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvzf ioncube_loaders_lin_x86-64.tar.gz
rm ioncube_loaders_lin_x86-64.tar.gz
cd ioncube

php_ext_dir="$(php -r 'echo ini_get("extension_dir");' 2>/dev/null)"
php_version="$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;' 2>/dev/null)"

if [ "$php_version" == "7.4" ]; then
    php_ext_dir="$(php -i | grep extension_dir 2>/dev/null | head -n 1 | cut --characters=31-39)"
fi

cp ioncube_loader_lin_${php_version}.so /usr/lib/php/${php_ext_dir}
cd ..
rm -rf ioncube

cat > /etc/php/${php_version}/cli/conf.d/00-ioncube-loader.ini << EOF
zend_extension=ioncube_loader_lin_${php_version}.so
EOF

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
