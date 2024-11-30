#!/bin/bash
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
