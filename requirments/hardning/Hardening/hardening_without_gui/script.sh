#!/bin/bash

mkdir /root/cdrom
mount /dev/sr0 /root/cdrom
cp media.repo /etc/yum.repos.d/
cp mediabase.repo /etc/yum.repos.d/
echo "/dev/sr0     /root/cdrom     iso9660 defaults        1 2" >> /etc/fstab
yum update
cp hardening.conf /etc/modprobe.d/
cp usb-auth.sh /opt/
cp usb-auth.service /etc/systemd/system/
chmod 0700 /opt/usb-auth.sh
systemctl enable usb-auth.service
systemctl start usb-auth.service
sed -i 's#GRUB_CMDLINE_LINUX="crashkernel=auto resume=/dev/mapper/rhel-swap rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet"#GRUB_CMDLINE_LINUX="crashkernel=auto resume=/dev/mapper/rhel-swap rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet nousb"#g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
cp sysctl.conf /etc/
sysctl -p
sed -i -e 's/umask 022/umask 027/g' -e 's/umask 002/umask 027/g' /etc/bashrc
sed -i -e 's/umask 022/umask 027/g' -e 's/umask 002/umask 027/g' /etc/csh.cshrc
sed -i -e 's/umask 022/umask 027/g' -e 's/umask 002/umask 027/g' /etc/profile
sed -i -e 's/umask 022/umask 027/g' -e 's/umask 002/umask 027/g' /etc/init.d/functions
echo "*    hard    core    0" >> /etc/security/limits.conf
#cat limits.conf >> /etc/security/limits.conf
find / -ignore_readdir_race -nouser -print -exec chown root {} \;
find / -ignore_readdir_race -nogroup -print -exec chgrp root {} \;
find / -ignore_readdir_race -not -path "/proc/*" -nouser -print -exec chown root {} \;
cp unowned_files /etc/cron.daily/
chmod 0700 /etc/cron.daily/unowned_files
find / -xdev -type f -perm -4000 -o -perm -2000
sed -i "s/DefaultZone=.*/DefaultZone=drop/g" /etc/firewalld/firewalld.conf
systemctl stop firewalld.service
systemctl mask firewalld.service
systemctl daemon-reload
#yum install -y iptables-service
#systemctl enable iptables.service
cp host.allow /etc/
cp host.deny /etc/
cp sysctl1 >> sysctl.conf
cp sysctl.conf /etc/
cat sysctl1 >> /etc/sysctl.d/50-libreswan.conf
cp hardening.conf /etc/modprobe.d/
for i in $(find /lib/modules/$(uname -r)/kernel/drivers/net/wireless -name "*.ko" -type f);do \
  echo blacklist "$i" >>/etc/modprobe.d/hardening-wireless.conf;done
nmcli radio all off
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
echo "NETWORKING_IPV6=no" >> /etc/sysconfig/network
echo "IPV6INIT=no" >> /etc/sysconfig/network
ip link | grep PROMISC
sed -i 's#BOOTPROTO=dhcp#BOOTPROTO=static#g' /etc/sysconfig/network-scripts/ifcfg-ens192
sed -i 's#IPV6_AUTOCONF=yes#IPV6_AUTOCONF=no#g' /etc/sysconfig/network-scripts/ifcfg-ens192
sed -i 's#IPV6_DEFROUTE=yes#IPV6_DEFROUTE=no#g' /etc/sysconfig/network-scripts/ifcfg-ens192
sed -i 's#ONBOOT=no#ONBOOT=yes#g' /etc/sysconfig/network-scripts/ifcfg-ens192
userdel -r adm
userdel -r ftp
userdel -r games
userdel -r lp
groupdel games
authconfig --passalgo=sha512  --passminlen=16  --passminclass=4  --passmaxrepeat=2 --passmaxclassrepeat=2  --enablereqlower  --enablerequpper  --enablereqdigit  --enablereqother  --update
sed -i 's/\# difok = 1/difok = 1/g' /etc/security/pwquality.conf
sed -i 's/\# gecoscheck = 0/gecoscheck = 0/g' /etc/security/pwquality.conf
sed -i 's/\<nullok\>//g' /etc/pam.d/system-auth /etc/pam.d/system-auth
sed -i 's/\<nullok\>//g' /etc/pam.d/password-auth /etc/pam.d/password-auth
sed -i 's/INACTIVE=-1/INACTIVE=0/g' /etc/default/useradd
sed -i -e 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 60/'   -e 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/'   -e 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 14/'   -e 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs
echo "FAILLOG_ENAB  yes" >> /etc/login.defs
echo "FAIL_DELAY  4" >> /etc/login.defs
grub2-setpassword
grub2-mkconfig -o /boot/grub2/grub.cfg
chmod 0600 /boot/grub2/grub.cfg
systemctl mask ctrl-alt-del.target
#echo "Unauthorised access prohibited. Logs are recorded and monitored." >> /etc/issue
#echo "Unauthorised access prohibited. Logs are recorded and monitored." >> /etc/issue.net
echo "readonly  TMOUT=900" >> /etc/profile
sed -i 's/HISTSIZE=1000/HISTSIZE=5000/g' /etc/profile
sed -i 's#max_log_file = 10#max_log_file = 25#g' /etc/audit/auditd.conf
sed -i 's#space_left = 75#space_left = 30#g' /etc/audit/auditd.conf
sed -i 's#space_left_action = SYSLOG#space_left_action = email#g' /etc/audit/auditd.conf
sed -i 's#admin_space_left_action = SUSPEND#admin_space_left_action = email#g' /etc/audit/auditd.conf
chown root:root /etc/audit/rules.d/audit.rules
chmod 0640 /etc/audit/rules.d/audit.rules
cat audit1.rules >> /etc/audit/rules.d/audit.rules
systemctl enable auditd.service
systemctl start auditd.service
sed -i 's#GRUB_CMDLINE_LINUX="crashkernel=auto resume=/dev/mapper/rhel-swap rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet nousb"#GRUB_CMDLINE_LINUX="crashkernel=auto resume=/dev/mapper/rhel-swap rd.lvm.lv=rhel/root rd.lvm.lv=rhel/swap rhgb quiet nousb audit=1"#g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
yum install -y aide.x86_64
/usr/sbin/aide --init
cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
/usr/sbin/aide --check
sed -i 's/\#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
sed -i 's/\#SystemMaxUse=/SystemMaxUse=256M/g' /etc/systemd/journald.conf
sed -i 's/\#SystemKeepFree=/SystemKeepFree=512M/g' /etc/systemd/journald.conf
sed -i 's/\#SystemKeepFree=/SystemKeepFree=512M/g' /etc/systemd/journald.conf
systemctl daemon-reload
systemctl restart systemd-journald
chmod 0600 /etc/ssh/*_key
cp sshd_config /etc/ssh/
yum install -y policycoreutils
systemctl enable chronyd.service
yum install -y postfix
systemctl enable postfix.service
sed -i 's/\#smtpd_banner = $myhostname ESMTP $mail_name/smtpd_banner = $myhostname ESMTP/g' /etc/postfix/main.cf
sed -i 's/smtpd_banner = $myhostname ESMTP ($mail_version)/\#smtpd_banner = $myhostname ESMTP ($mail_version)/g' /etc/postfix/main.cf
sed -i 's/inet_interfaces = localhost/inet_interfaces = loopback-only/g' /etc/postfix/main.cf
sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
sed -i 's/mydestination = $myhostname, localhost.$mydomain, localhost/mydestination = /g' /etc/postfix/main.cf
echo "local_transport = error: local delivery disabled" >> /etc/postfix/main.cf
echo "mynetworks = 127.0.0.0/8" >> /etc/postfix/main.cf
yum install -y cyrus-sasl-plain
echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf
echo "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd" >> /etc/postfix/main.cf
echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf
echo "smtp_tls_CApath = /etc/ssl/certs" >> /etc/postfix/main.cf
echo "smtp_use_tls = yes" >> /etc/postfix/main.cf
yum remove xinetd telnet-server rsh-server telnet rsh ypbind ypserv tfsp-server bind vsfptd dovecot squid net-snmpd talk-server talk
systemctl list-unit-files --type=service|grep enabled
systemctl disable kdump.service
systemctl mask kdump.service
systemctl disable tuned.service
rm -rf /etc/at.deny /etc/cron.deny
yum install -y sysstat
systemctl enable sysstat.service
systemctl start sysstat.service
################################################################################New################################################
echo "05 4 * * * root  /usr/sbin/aide --check" >> /etc/crontab
echo "[org/gnome/login-screen]" >> /etc/dconf/db/gdm.d/00-security-settings
echo "banner-message-enable=true" >> /etc/dconf/db/gdm.d/00-security-settings
echo "banner-message-text='APPROVED_BANNER'" >> /etc/dconf/db/gdm.d/00-security-settings
echo "/org/gnome/login-screen/banner-message-enable" >> /etc/dconf/db/gdm.d/locks/00-security-settings-lock
echo "/org/gnome/login-screen/banner-message-text" >> /etc/dconf/db/gdm.d/locks/00-security-settings-lock
dconf update
df --local -P | awk '{if (NR!=1) print $6}' | sudo xargs -I '{}' find '{}' -xdev -nogroup
cp /etc/sudoers /etc/sudoers.bak
echo "Defaults use_pty" >> /etc/sudoers
echo 'Defaults logfile=/var/log/sudo.log' >> /etc/sudoers
echo 'Defaults log_host, log_year, logfile="/var/log/sudo.log"' >> /etc/sudoers
echo "###########################################################################" >> /etc/pam.d/password-auth
echo "###########################################################################" >> /etc/pam.d/system-auth
echo "password    required    pam_pwhistory.so    remember=5    use_authtok" >> /etc/pam.d/password-auth
echo "password    required    pam_pwhistory.so    remember=5    use_authtok" >> /etc/pam.d/system-auth
mv /etc/issue /etc/issue.bak
cp issue /etc/
chgrp root /etc/issue
chown root /etc/issue
systemctl enable --now cockpit.socket 
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.bak
sed -i 's+# minclass = 0+minclass = 4+g' /etc/security/pwquality.conf
sed -i 's+# minlen = 8+minlen = 10+g' /etc/security/pwquality.conf
sed -i 's+# retry = 3+retry = 3+g' /etc/security/pwquality.conf
cp /etc/pam.d/su /etc/pam.d/su.bak
echo "#############################################################################" >> /etc/pam.d/su
echo "auth    required    pam_wheel.so    use_uid" >> /etc/pam.d/su
cp /etc/login.defs /etc/login.defs.bak
sed -i 's/PASS_MIN_DAYS 1/PASS_MIN_DAYS 7/g' /etc/login.defs
sed -i 's/022/027/g' /etc/login.defs
echo "TMOUT=900" >> /etc/profile.d/tmout.sh
cp /etc/systemd/journald.conf /etc/systemd/journald.conf.bak
sed -i 's+#Compress=yes+Compress=yes+g' /etc/systemd/journald.conf
systemctl mask --now avahi-daemon.service
systemctl mask --now avahi-daemon.socket
chmod 0700 /etc/cron.d
chmod 0700 /etc/cron.daily
chmod 0700 /etc/cron.hourly
chmod 0700 /etc/cron.monthly
chmod 0700 /etc/cron.weekly
chmod 0600 /etc/crontab
yum erase -y openldap-clients
cp /etc/sysconfig/chronyd /etc/sysconfig/chronyd.bak
sed -i 's/OPTIONS=""/OPTIONS="-u chrony"/g' /etc/sysconfig/chronyd
systemctl mask --now cups.service
systemctl mask --now cups.socket
chmod +t /var/tmp
chmod +t /tmp
sed -i 's+#ProcessSizeMax=2G+ProcessSizeMax=2G+g' /etc/systemd/coredump.conf
sed -i 's+#Storage=external+Storage=none+g' /etc/systemd/coredump.conf
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.conf.default.rp_filter=1
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.ip_forward=0
echo 0 > /proc/sys/net/ipv4/ip_forward
yum install -y openscap
yum install -y scap-workbench
yum install -y openscap-scanner
yum install -y scap-security-guide-doc.noarch
oscap info /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_server_l1 --results-arf arf.xml --report Level1_Report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis --results-arf arf.xml --report Level2_Report.html /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
fips-mode-setup --enable
yum remove xorg-x11-server-Xorg xorg-x11-server-common xorg-x11-server-utils xorg-x11-server-Xwayland
