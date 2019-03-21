#!/bin/bash
# Script to configure tux61
AUTHOR='CarlosANovo'
if ! [ $(id -u) = 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

echo 'Updating and installing necessary packages...'
apt update
apt install -y curl wget

echo 'Downloading files'
wget https://github.com/${AUTHOR}/pgre/archive/master.zip
echo 'Unpacking files'
unzip master.zip

echo ' === Installing Apache Web Server === '
apt install -y apache2
mkdir -p /var/www/pgre.fe.up.pt/html
chown -R $USER:$USER /var/www/pgre.fe.up.pt/html
chmod -r 755 /var/www/pgre.fe.up.pt

echo 'Inserting content into the Web page...'
cp -r pgre-master/tux61/html/* /var/www/pgre.fe.up.pt/html
cp pgre-master/tux61/pgre.fe.up.pt.conf /etc/apache2/sites-available/pgre.fe.up.pt.conf

echo 'Enabling the Vitual Host...'
a2ensite pgre.fe.up.pt
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
apt install -y net-tools wget lsof postfix mailutils
cp /etc/postfix/main.cf{,.backup}
cp pgre-master/tux61/main.cf /etc/postfix/main.cf
echo 'Restarting and enabling mail server...'
systemctl restart postfix
systemctl enable postfix
echo 'Installing IMAP agent...'
apt install -y dovecot-core dovecot-imapd
cp /etc/dovecot/dovecot.conf{,.backup}
cp pgre-master/tux61/dovecot.conf /etc/dovecot/dovecot.conf
cp /etc/dovecot/conf.d/10-auth.conf{,.backup}
cp pgre-master/tux61/10-auth.conf /etc/dovecot/conf.d/10-auth.conf
cp /etc/dovecot/conf.d/10-mail.conf{,.backup}
cp pgre-master/tux61/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
cp /etc/dovecot/conf.d/10-master.conf{,.backup}
cp pgre-master/tux61/10-master.conf /etc/dovecot/conf.d/10-master.conf
echo 'Restarting IMAP agent...'
systemctl restart dovecot.service
systemctl enable dovecot.service
echo 'Installing Webmail service...'
apt install -y php7.0 libapache2-mod-php7.0 php7.0-curl php7.0-xml
mkdir -p /var/www/mail.pgre.fe.up.pt/html
chown -R $USER:$USER /var/www/mail.pgre.fe.up.pt/html
chmod -r 755 /var/www/mail.pgre.fe.up.pt
cd /var/www/mail.pgre.fe.up.pt/html
curl -sL https://repository.rainloop.net/installer.php | php

cp pgre-master/tux61/mail.pgre.fe.up.pt.conf /etc/apache2/sites-available/mail.pgre.fe.up.pt.conf
a2ensite mail.pgre.fe.up.pt
systemctl restart apache2
echo 'Webmail service installed, please configure.'

# ADD USERS AND MAKE THEIR FOLDERS
echo ' === Adding users === '
echo 'export MAIL=$HOME/.maildir' >> /etc/profile
addgroup webadminsgroup
chgrp -R webadminsgroup /var/www
chmod -R g+w /var/www
echo 'webadmin...'
useradd -m -c "Web Administrator" -s /bin/bash -G webadminsgroup webadmin
echo -e "internet123\ninternet123" | passwd webadmin
echo "webadmin" | tee -a /etc/vsftpd.userlist
mkdir /home/webadmin/ftp
chown nobody:nogroup /home/webadmin/ftp
chmod a-w /home/webadmin/ftp
mkdir /home/webadmin/ftp/files
chown -R webadmin:webadmin /home/webadmin/ftp/files
chmod -R 0770 /home/webadmin/ftp/files/
mkdir /home/webadmin/ftp/www
chown -R webadmin:webadmin /home/webadmin/ftp/www
chmod -R 0770 /home/webadmin/ftp/www/
mount /var/www /home/webadmin/ftp/www -o bind

echo 'john...'
useradd -m -c "John" -s /bin/bash john
echo -e "john.1980\njohn.1980" | passwd john
echo "john" | tee -a /etc/vsftpd.userlist
mkdir /home/john/ftp
chown nobody:nogroup /home/john/ftp
chmod a-w /home/john/ftp
mkdir /home/john/ftp/files
chown -R john:john /home/john/ftp/files
chmod -R 0770 /home/john/ftp/files/

echo 'alice...'
useradd -m -c "Alice" -s /bin/bash alice
echo -e "alice.1990\nalice.1990" | passwd alice
echo "alice" | tee -a /etc/vsftpd.userlist
mkdir /home/alice/ftp
chown nobody:nogroup /home/alice/ftp
chmod a-w /home/alice/ftp
mkdir /home/alice/ftp/files
chown -R alice:alice /home/alice/ftp/files
chmod -R 0770 /home/alice/ftp/files/

echo 'bob...'
useradd -m -c "Robert" -s /bin/bash bob
echo -e "bob.1234\nbob.1234" | passwd bob
echo "bob" | tee -a /etc/vsftpd.userlist
mkdir /home/bob/ftp
chown nobody:nogroup /home/bob/ftp
chmod a-w /home/bob/ftp
mkdir /home/bob/ftp/files
chown -R bob:bob /home/bob/ftp/files
chmod -R 0770 /home/bob/ftp/files/

echo "admin: root" >> /etc/aliases
newaliases

# remove the temporary files
