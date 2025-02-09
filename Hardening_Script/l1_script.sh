#!/bin/bash

#1. initial setup 

#1.1.Configure /tmp
#Audit 
findmnt --kernel /tmp

#Remediation
systemctl unmask tmp.mount 
systemctl start tmp.mount 
systemctl enable tmp.mount 
echo "tmpfs  /tmp  tmpfs  defaults,rw,nosuid,nodev,noexec,relatime,size=2G 0" | tee -a /etc/fstab
mount -a
###########################################################################################################

#1.2.Configure /var
#Audit
findmnt --kernel /var

#Remediation  
sed -i '/\/var/s/^/#/' /etc/fstab
echo "/dev/mapper/rhel-var  /var  xfs  defaults,rw,nosuid,nodev,noexec,relatime  0  0" | tee -a /etc/fstab
mount -o remount /var
###########################################################################################################

#1.3. Configure /home
#Audit
findmnt --kernel /home

#Remediation
sed -i '/\/home/s/^/#/' /etc/fstab
echo "/dev/mapper/rhel-home  /home  xfs  defaults,rw,nosuid,nodev,noexec,relatime 0 0" | tee -a /etc/fstab
mount -o remount /home
###########################################################################################################

#1.4. Ensure gpgcheck is globally activated
#Audit
grep ^gpgcheck /etc/dnf/dnf.conf

#Remediation - manual

#1.5.  Ensure package manager repositories are configured
#Audit
dnf repolist
#Remediation 
mkdir /cdrom
mount /dev/sr0 /cdrom
cp -r local.repo /etc/yum.repos.d/
yum update -y 


#1.6. Filesystem Integrity Checking 
#Audit 
rpm -q aide 
	
#Remediation
dnf install aide -y
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

#1.7.  Ensure filesystem integrity is regularly checked]
#Audit 
grep -ir "aide" /etc/crontab

#Remediation
echo "0 5 * * * /usr/sbin/aide --check" | tee -a /etc/crontab

#1.8. ensure cryptographic mechanisms are used to protect the integrity of audit tools
#Audit 
grep -ir "sbin "/etc/aide.conf

#Remediation 
tee -a /etc/aide.conf << EOF
/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
EOF

#1.9. Secure Boot Settings
#Audit 
awk -F. '/^\s*GRUB2_PASSWORD/ {print $1"."$2"."$3}' /boot/grub2/user.cfg

#Remediation
grub2-setpassword

#1.10. Ensure permissions on bootloader config are configured
#Audit 
stat -Lc "%n %#a %u/%U %g/%G" /boot/grub2/grub.cfg
stat -Lc "%n %#a %u/%U %g/%G" /boot/grub2/grubenv
stat -Lc "%n %#a %u/%U %g/%G" /boot/grub2/user.cfg

#Remediation
chown root:root /boot/grub2/grub.cfg
chmod og-rwx /boot/grub2/grub.cfg

chown root:root /boot/grub2/grubenv
chmod u-x,og-rwx /boot/grub2/grubenv

chown root:root /boot/grub2/user.cfg
chmod u-x,og-rwx /boot/grub2/user.cfg

#1.11. Ensure core dump storage is disabled
#Audit
grep -ir '^\s*storage\s*=\s*none' /etc/systemd/coredump.conf

#Remediation
sed -i 's/#\?Storage=.*/Storage=none/' /etc/systemd/coredump.conf


#1.12. Ensure core dump backtraces are disabled
#Audit
grep -ir "ProcessSizeMax" /etc/systemd/coredump.conf

#Remediation
sed -i 's/#\?ProcessSizeMax=.*/ProcessSizeMax=0/' /etc/systemd/coredump.conf

#1.13.  Disable Selinux 
#Audit
grep -ir "SELINUX" /etc/selinux/config

#Remediation
sed -i 's/#\?SELINUX=.*/SELINUX=disabled/' /etc/selinux/config


#1.14. Ensure the MCS Translation Service (mcstrans) is not installed (Automated)
#Audit
rpm -q mcstrans

#Remediation
dnf remove mcstrans

#1.15. Command Line Warning Banners
#Audit
cat /etc/motd
cat /etc/issue
cat /etc/issue.net 

stat -L /etc/motd
stat -L /etc/issue
stat -L /etc/issue.net


#Remediation
tee -a /etc/motd << EOF
Welcome to Natgrid!
This is your Master Template VM
********** Authorized uses only **********
All activity is  monitored and reported 
******************************************
EOF

chown root:root /etc/motd
chmod u-x,go-wx /etc/motd

tee -a /etc/issue << EOF
********** Authorized uses only **********
All activity is  monitored and reported 
******************************************
EOF

chown root:root /etc/issue
chmod u-x,go-wx /etc/issue

tee -a /etc/issue.net << EOF
********** Authorized uses only **********
All activity is  monitored and reported 
****************************************** 
EOF

chown root:root /etc/issue.net
chmod u-x,go-wx /etc/issue.net


#1.16. Configure system cryptographic policies
#Audit
update-crypto-policies --show

#Remediation 
update-crypto-policies --set DEFAULT

#1.17. enable authselect profile -sssd
#Audit
authselect current
#Remediation
authselect select --force sssd

# Ensure GNOME Display Manager is removed

# Ensure GDM login banner is configured -Skipped


#2. Services

#2.1. Ensure time synchronization is in use
#Audit
rpm -q chrony

#Remediation
dnf install chrony

#2.2. Ensure chrony is configured
#Audit
grep -E "^(server|pool)" /etc/chrony.conf

#Remediation
#Manually Enter  ntp server ip 
#in Format- server server_ip prefer iburst

#2.3.Ensure Avahi Server is not installed
#Audit 
rpm -q avahi

#Remediation
systemctl stop avahi-daemon.socket avahi-daemon.service
dnf remove avahi 

#2.4.Ensure CUPS is not installed
#Audit
rpm -q cups

#Remediation
dnf remove cups

#2.5. Ensure DHCP Server is not installed
#Audit 
rpm -q dhcp-server

#Remediation
dnf remove dhcp-server

#2.6. Ensure DNS Server is not installed
#Audit 
rpm -q bind

#Remediation
dnf remove bind

#2.7. Ensure VSFTP Server is not installed
#Audit 
rpm -q vsftpd

#Remediation
dnf remove vsftpd

#2.8. Ensure TFTP Server is not installed
#Audit 
rpm -q tftp-server

#Remediation
dnf remove tftp-server

#2.9. Ensure a web server is not installed -exlude vm's those for frontend and reverse proxy 
#Audit 
rpm -q httpd nginx

#Remediation
dnf remove httpd nginx

#2.10. Ensure IMAP and POP3 server is not installed
#Audit
rpm -q dovecot cyrus-imapd

#Remediation
dnf remove dovecot cyrus-imapd

#2.11. Ensure Samba is not installed
#Audit
rpm -q samba

#Remediation
dnf remove samba

#2.12. Ensure HTTP Proxy Server is not installed
#Audit 
rpm -q squid

#Remediation
dnf remove squid

#2.13. Ensure net-snmp is not installed
#Audit 
rpm -q net-snmp

#Remediation
dnf remove net-snmp

#2.14. Ensure telnet-server is not installed
#Audit 
rpm -q telnet-server

#Remediation
dnf remove telnet-server

#2.15. Ensure dnsmasq is not installed
#Audit 
rpm -q dnsmasq

#Remediation
dnf remove dnsmasq

#2.16. Ensure nfs-utils is not installed or the nfs-server service is masked - exlude those vm's which use nfs server and for client which use nfs 
#Audit
rpm -q nfs-utils

#Remediation
dnf remove nfs-utils

#2.17. Ensure rpcbind is not installed or the rpcbind services are masked - exlude those vm's which use nfs server and for client which use nfs
#Audit
rpm -q rpcbind

#Remediation
dnf remove rpcbind

#2.18. Ensure rsync-daemon is not installed or the rsyncd service is masked - skip if daily incremental backup is taken from rsync 
#Audit 
rpm -q rsync-daemon

#Remediation
dnf remove rsync-daemon

#2.19. Ensure telnet client is not installed
#Audit 
rpm -q telnet

#Remediation
dnf remove telnet

#2.20. Ensure LDAP client is not installed
#Audit
rpm -q openldap-clients

#Remedition
dnf remove openldap-clients

#2.21. Ensure TFTP client is not installed
#Audit
rpm -q tftp

#Remediation
dnf remove tftp


#2.22. Ensure FTP client is not installed
#Audit
rpm -q ftp

#Remediation
dnf remove ftp

#2.24. mcs translation service  (mctrans) is not installed
#Audit
rpm -q mctrans

#Remediation
dnf remove mctrans

#2.25. Ensure  setroubleshoot is not installed
#Audit
rpm -q setroubleshoot

#Remediation
dnf remove setroubleshoot-server -y


# Ensure nonessential services listening on the system are removed or masked (Manual): ss -plntu
# Ensure mail transfer agent is configured for local-onlymode -skipped not installed
# Ensure xorg-x11-server-common is not installed -skipped


#3. Network Configuration

#3.1. Ensure ]IPv6 status is identified - disbale ipv6 if no need 
#Audit
#cat /sys/module/ipv6/parameters/disable_ipv6
#cat /sys/module/ipv6/parameters/disable

#Remediation
#sed -i 's/0/1' /sys/module/ipv6/parameters/disable_ipv6
#sed -i 's/0/1' /sys/module/ipv6/parameters/disable

#3.2. Ensure wireless interfaces are disabled
#Audit 
ip link show 
ifconfig -a
nmcli device status

#Remediation
#wireless interface is not shown by default  in rhel 9

#3.3. Set Network Parameters (Host Only) 
#Audit
cat /etc/sysctl.conf
#Remediation
yes | cp -r 99-sysctl.conf /etc/sysctl.d/
sysctl -p /etc/sysctl.conf

#3.4. Configure host based firewall - disabled and masked

#Audit 
#systemctl status firewalld.service

#Remediation 
systemctl stop firewalld.service
systemctl disable firewalld.service
systemctl mask firewalld.service


#4. Logging and Auditing

#4.1. Ensure auditing is enabled

#All auditd rules script is skipped because of L2 hardening and this script is created seprately 

#4.2. Configure rsyslog
#Audit
rpm -q rsyslog
#systemctl status rsyslog.service

#Remediation
dnf install rsyslog
systemctl start rsyslog.service
systemctl enable rsyslog.service


#4.3. Ensure journald is configured to send logs to rsyslog
#Audit
#grep -ir "ForwardToSyslog" /etc/systemd/journald.conf

#Remediation
#sed -i 's/#\?ForwardToSyslog=.*/ForwardToSyslog=yes/' /etc/systemd/journald.conf
#systemctl restart rsyslog

#4.4. Ensure logging is configured - manual 

#4.5 Ensure rsyslog is configured to send logs to a remote log host - manual

#4.6 Ensure rsyslog is not configured to receive logs from a remote client - manual - exclude rsyslog server

#4.7. Ensure systemd-journal-remote is installed

#Audit
#rpm -q systemd-journal-remote

##Remediation
#dnf install systemd-journal-remote

#4.8. Ensure systemd-journal-remote is configured - manual

#4.9. Ensure journald is not configured to receive logs from a remote client
#Audit
systemctl is-enabled systemd-journal-remote.socket

#Remediation
systemctl stop systemd-journal-remote.socket
systemctl disable systemd-journal-remote.socket
systemctl --now mask systemd-journal-remote.socket

#4.10. Configure jounrald -manual 

#4.11. Ensure logrotate is configured - manual


#5. Access, Authentication and Authorization 

#5.1 Ensure cron daemon is enabled
#Audit
systemctl is-enabled crond

#Remediation
systemctl --now enable crond

#5.2 Ensure permissions on /etc/crontab are configured
#Audit
stat /etc/crontab

#Remediation
chown root:root /etc/crontab
chmod og-rwx /etc/crontab

#5.3. Ensure permissions on /etc/cron.hourly are configured
#Audit
stat /etc/cron.hourly

#Remediation
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly


#5.4. Ensure permissions on /etc/cron.daily are configured
#Audit
stat /etc/cron.daily

#Remediation
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily

#5.5. Ensure permissions on /etc/cron.weekly are configured
#Audit
stat /etc/cron.weekly

#Remediation
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly

#5.6. Ensure permissions on /etc/cron.monthly are configured
#Audit
stat /etc/cron.monthly

#Remediation
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly 


#5.7. Ensure permissions on /etc/cron.d are configured
#Audit
stat /etc/cron.d

#Remediation
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d


#5.8. Ensure cron is restricted to authorized users -manual

#5.9. Ensure at is restricted to authorized users - manual  

#5.10. Ensure permissions on /etc/ssh/sshd_config are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/ssh/sshd_config

#Remediation
chown root:root /etc/ssh/sshd_config
chmod u-x,go-rwx /etc/ssh/sshd_config

#5.11. Configure sshd service 
#Audit
cat /etc/ssh/sshd_config

#Remediation
yes | cp -r sshd_config /etc/ssh/

#5.12. Configure privilege escalation
#Audit
dnf list sudo

#Remediation
dnf install sudo

#5.13. Ensure sudo commands use pty
#Audit 
grep -ir "Defaults use_pty" /etc/sudoers

#Remediation
echo "Defaults use_pty" | tee -a /etc/sudoers
 
#5.14. Ensure sudo log file exists
#Audit
grep -ir "Defaults logfile='/var/log/sudo.log'"  /etc/sudoers

#Remedition
echo "Defaults logfile=/var/log/sudo.log"  | tee -a /etc/sudoers  

#5.15. Ensure sudo authentication timeout is configured correctly
#Audit
cat /etc/sudoers

#Remediation
tee -a /etc/sudoers << EOF
Defaults env_reset, timestamp_timeout=15
Defaults timestamp_timeout=15
Defaults env_reset
EOF

#5.16. Ensure access to su command is restricted -skipped or done manually

#5.17. Ensure authselect includes with-faillock
#Audit
grep pam_faillock.so /etc/pam.d/password-auth /etc/pam.d/system-auth

#Remediation
authselect enable-feature with-faillock
authselect apply-changes -b

#5.18. Configure PAM
#Audit
cat /etc/security/pwquality.conf
cat /etc/security/faillock.conf
#Remediation
yes | cp -r pwquality.conf /etc/security
yes | cp -r faillock.conf /etc/security


#5.19. Ensure password reuse is limited
#Audit
grep -ir "remember" /etc/security/pwhistory.conf
#Remediation
echo "remember = 5" | tee -a /etc/security/pwhistory.conf
authselect enable-feature with-pwhistory

#5.20. Ensure password hashing algorithm is SHA-512 or yescrypt
#Audit
grep -ir "sha 512" /etc/libuser.conf
grep -ir "sha 512" /etc/login.defs

#Remember
#Already checked its default sha 512 in rhel9

#5.21. configure login.defs
#Audit
cat /etc/login.defs

#Remediation
yes | cp -r login.defs /etc/

#5.22. Ensure inactive password lock is 30 days or less
#Audit
useradd -D | grep INACTIVE

#Remediation
useradd -D -f 30

#5.23. Ensure system accounts are secured -checked manually

#5.24. nsure default group for the root account is GID 0
#Audit
grep "^root:" /etc/passwd | cut -f4 -d:
#Remediation
#it's already 0 by default

#5.25. Ensure access to the su command is restricted
#Audit
grep -ir "auth" /etc/pam.d/su

#Remediation
groupadd sugroup
usermod -aG sugroup admin2
echo "auth            required        pam_wheel.so    use_uid group=sugroup" | tee -a /etc/pam.d/su

#5.26. Ensure default user shell timeout is 900 seconds or less
#Audit 
echo $TMOUT

#Remediation
yes | cp -r tmout.sh /etc/profile.d/
source /etc/profile

#Apply authselect changes
authselect apply-changes -b

#6. System maintanance

#6.1.Ensure permissions on /etc/passwd are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/passwd

#Remediation
chmod u-x,go-wx /etc/passwd
chown root:root /etc/passwd

#6.2. Ensure permissions on /etc/passwd- are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/passwd-

#Remediation
chmod u-x,go-wx /etc/passwd-
chown root:root /etc/passwd-

#6.3. Ensure permissions on /etc/group are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/group

#Remediation
chmod u-x,go-wx /etc/group
chown root:root /etc/group

#6.4. Ensure permissions on /etc/group- are configure
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/group-

#Remediation
chmod u-x,go-wx /etc/group-
chown root:root /etc/group-

#6.5. Ensure permissions on /etc/shadow are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/shadow

#Remediation
chown root:root /etc/shadow
chmod 0000 /etc/shadow

#6.6. Ensure permissions on /etc/shadow- are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/shadow-

#Remediation
chown root:root /etc/shadow-
chmod 0000 /etc/shadow

#6.7. Ensure permissions on /etc/gshadow are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/gshadow

#Remediation
chown root:root /etc/gshadow
chmod 0000 /etc/gshadow

#6.8. Ensure permissions on /etc/gshadow- are configured
#Audit
stat -Lc "%n %a %u/%U %g/%G" /etc/gshadow-

#Remediation
chown root:root /etc/gshadow-
chmod 0000 /etc/gshadow-

#6.9. Ensure no world writable files exist -  need to do manually

#6.10. Ensure no unowned files or directories exist - need to do manually

#6.11. Ensure no ungrouped files or directories exist - need to do manually

#6.12. Ensure sticky bit is set on all world-writable directories - need to do manually

#6.13. Audit SUID executables - need to do manually

#6.14. Audit SGID executables - need to do manually

#6.15. Audit system file permissions - need to do manually

#6.16. Ensure accounts in /etc/passwd use shadowed passwords 
#Audit
awk -F: '($2 != "x" ) { print $1 " is not set to shadowed passwords "}' /etc/passwd
#Remediation
#default as account use shadowed passwords in rhel 9

