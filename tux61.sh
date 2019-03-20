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

echo ' === Installing Apache Web Server === '
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
systemctl enable apache2

echo ' === Installing the NTP server === '
apt install -y ntp
cp /etc/ntp.conf{,.backup}
cp pgre-master/tux61/ntp.conf /etc/ntp.conf
systemctl restart ntp
systemctl enable ntp

echo ' === Installing FTP server === '
apt install -y vsftpd
cp /etc/vsftpd.conf{,.backup}
cp pgre-master/tux61/vsftpd.conf /etc/vsftpd.conf
systemctl restart vsftpd
systemctl enable vsftpd

# ADD USERS AND MAKE THEIR FOLDERS
# useradd -m -c "Name" -s /bin/bash username
# passwd username
# echo "username" | tee -a /etc/vsftpd.userlist
# mkdir /home/username/ftp
# chown nobody:nogroup /home/username/ftp
# chmod a-w /home/username/ftp
# mkdir /home/username/ftp/files
# chown -R username:username /home/username/ftp/files
# chmod -R 0770 /home/username/ftp/files/

echo ' === Installing DNS server === '
apt install -y bind9 bind9utils
cp pgre-master/tux61/bind9 /etc/default/bind9
cp /etc/bind/named.conf.options{,.backup}
cp pgre-master/tux61/named.conf.options /etc/bind/named.conf.options
cp /etc/bind/named.conf.local{,.backup}
cp pgre-master/tux61/named.conf.local /etc/bind/named.conf.local
echo 'Making the databases...'
mkdir /etc/bind/zones
cp pgre-master/tux61/db.1.16.172 /etc/bind/zones/db.1.16.172
cp pgre-master/tux61/db.pgre.fe.up.pt /etc/bind/zones/db.pgre.fe.up.pt
echo 'Checking correct configuration...'
named-checkconf
named-checkzone pgre.fe.up.pt /etc/bind/zones/db.pgre.fe.up.pt
named-checkzone 1.16.172.in-addr.arpa /etc/bind/zones/db.1.16.172
echo 'Restarting and enabling DNS server...'
systemctl restart bind
systemctl enable bind

echo ' === Installing e-mail server === '

# also make the webserver for the e-mail


# remove the temporary files
