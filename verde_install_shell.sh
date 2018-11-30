#!/bin/sh

#to make sure if you connect the USB that included VERDE rpm


echo "!!set root password!! please enter the password that you want twice :)"
sudo passwd #root passwd 

su-



echo -e "\n Please make sure you connnect the USB that included VERDE rpm!!"

echo ""
echo ""

echo "-------------------------------------------"
echo "-----------VERDE Server Setting------------"
echo "-------------------------------------------"
echo "Do you want to setup your network connectivity? (y/n)"
read -r answer


# ip setting
if [ "$answer" = 'y' ] || [ "$answer" = 'Y' ];  then
touch /home/onboot.txt
touch /home/onboot1.txt
touch /home/onboot2.txt
touch /home/ip.txt
touch /home/netmask.txt
touch /home/gateway.txt
touch /home/gateway1.txt

#copy origianl network scripts to /home/onboot.txt
cp -r /etc/sysconfig/network-scripts/ifcfg-eth0 /home/onboot.txt

#delate certain row and append
sed '/ONBOOT/d' </home/onboot.txt > /home/onboot1.txt
echo "ONBOOT=yes" >> /home/onboot1.txt

sed '/BOOTPROTO/d' < /home/onboot1.txt > /home/onboot2.txt
echo "BOOTPROTO=static" >> /home/onboot2.txt

# IP setting 
echo -e "\nEnter your IP address to access internet"
read -r server_IP

# SUBNETMASK setting
echo -e "\nEnter your SUBNETMASK address to access internet"
read -r server_netmask

# GATEWAY setting
echo -e "\nEnter your GATEWAY address to access internet"
read -r server_gateway


#ip, netmask, gateway row delate and append
sed '/IPADDR/d' </home/onboot2.txt > /home/ip.txt
echo 'IPADDR='"$server_IP" >> /home/ip.txt

sed '/NETMASK/d' </home/ip.txt > /home/netmask.txt
echo 'NETMASK='"$server_netmask" >> /home/netmask.txt

cp -r /home/netmask.txt /etc/sysconfig/network-scripts/ifcfg-eth0 

cp /etc/sysconfig/network /home/gateway.txt
sed '/GATEWAY/d' </home/gateway.txt > /home/gateway1.txt
echo 'GATEWAY='"$server_gateway" >> /home/gateway1.txt

cp -r /home/gateway1.txt /etc/sysconfig/network


#delate all txt files that were used to access internet
rm -r /home/onboot*.txt
rm -r /home/ip.txt
rm -r /home/netmask.txt
rm -r /home/gateway*.txt

#restart network
/etc/init.d/network restart

#be allocated nameserver from DHCP server
dhclient

fi

sleep 3


#yum update
yum -y update

sleep 3


#install what we need to use VERDE service
yum --enablerepo=updates --enablerepo=base --assumeyes install java-1.8.0-openjdk.x86_64
yum --enablerepo=updates --enablerepo=base --assumeyes install gtk2
yum --enablerepo=updates --enablerepo=base --assumeyes install zip unzip
yum --enablerepo=updates --enablerepo=base --assumeyes install ntpdate ntp-doc

sleep 1

#make ntpd turn on at boot time
chkconfig ntpd on

/etc/init.d/ntpd start

sleep 1

#create "vb-verde" account Id/password
useradd vb-verde
echo "Set vb-verde's password"
passwd vb-verde

#account "vb-verde" make under the root group
usermod -G root vb-verde

sleep 1

echo "-nproc -1" > /etc/security/limits.d/95-verde.conf
echo "-nofile 65535" >> /etc/security/limits.d/95-verde.conf

sleep 1

#confirm java version
echo -e "\n\n"
echo "-------------------------------------------"
echo "Set JAVA 8 as the default java version"
echo "-------------------------------------------"
sudo update-alternatives --config java


sleep 1
#stop iptable
/etc/init.d/iptables stop


sleep 1

#make iptables turn off at boot time
chkconfig iptables off

sleep 1

#selinux disabled
touch /home/selinux.txt
touch /home/selinux1.txt
cp /etc/sysconfig/selinux /home/selinux.txt
sed 's/enforcing/disabled/' /home/selinux.txt > /home/selinux1.txt
cp -r /home/selinux1.txt /etc/sysconfig/selinux
rm -r /home/selinux*.txt

#verde rpm download

var1=$(fdisk -l |grep Disk | grep /dev/sd | tail -1 |awk '{print $2}')
var2=`echo $var1 | cut -c1-8`
#mkdir /home/USB123
#mount $var2 /home/USB123
find / -name 'VERDE*.rpm' -exec yum --nogpgcheck -y install {} \;  #find and install 
find / -name 'VERDE*.rpm' -exec yum --nogpgcheck -y install {} \;  #find and install 
find / -name 'VERDE*.rpm' -exec yum --nogpgcheck -y install {} \;  #find and install 


sleep3

umount /home/USB123
rm -r /home/USB123


/usr/lib/verde/bin/verde-config -i
