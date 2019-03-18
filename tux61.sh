#!/bin/bash
# Script to configure tux61
AUTHOR='CarlosANovo'
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

apt update
apt install -y curl

echo 'Downloading files'
wget https://github.com/${AUTHOR}/pgre/archive/master.zip
echo 'Unpacking files'
unzip master.zip

echo 'Installing Apache Web Server'
apt install -y apache2
mkdir -p /var/www/tux61.pgre.fe.up.pt/html
chown -R $USER:$USER /var/www/tux61.pgre.fe.up.pt/html
chmod -r 755 /var/www/tux61.pgre.fe.up.pt

echo 'Inserting content into the Web page...'
cp -r pgre-master/tux61/html/* /var/www/tux61.pgre.fe.up.pt/html
cp pgre-master/tux61/tux61.pgre.fe.up.pt.conf /etc/apache2/sites-available/tux61.pgre.fe.up.pt.conf

echo 'Enabling the Vitual Host...'
a2ensite tux61.pgre.fe.up.pt
systemctl restart apache2


echo '...'
# remove the temporary files