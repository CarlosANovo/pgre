#!/bin/bash
# Script to configure tux62
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

echo ' === Installing DNS server & Client === '
apt install -y bind9 bind9utils
cp pgre-master/tux61/bind9 /etc/default/bind9
cp /etc/bind/named.conf.options{,.backup}
cp pgre-master/others/named.conf.options /etc/bind/named.conf.options
cp /etc/bind/named.conf.local{,.backup}
cp pgre-master/others/named.conf.local /etc/bind/named.conf.local
echo 'Checking correct configuration...'
named-checkconf
echo 'Restarting and enabling DNS server...'
systemctl restart bind
systemctl enable bind

echo 'Adding Nameservers...'
cp pgre-master/others/tux62_interfaces /etc/network/interfaces
apt install -y resolvconf
ifdown --force eth0 && ip addr flush dev eth0 && ifup --force eth0

echo ' === Configuring NTP client === '
apt install -y ntp ntpdate
cp pgre-master/others/ntp.conf /etc/ntp.conf
cp pgre-master/others/ntpdate /etc/default/ntpdate
service ntp restart
