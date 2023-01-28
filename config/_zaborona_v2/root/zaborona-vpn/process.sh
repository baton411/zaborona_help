#!/bin/bash
set -e

# Generate knot-resolver aliases
#cp result/knot-aliases-alt.conf /etc/knot-resolver/knot-aliases-alt.conf
#systemctl restart kresd@1.service

# Generate dnsmasq aliases
cp result/dnsmasq-aliases-alt.conf /etc/dnsmasq.d/zaborona-dns-resovler
#systemctl restart dnsmasq

# Generate OpenVPN route file
cp result/openvpn-blocked-ranges.txt /etc/openvpn/server/ccd/DEFAULT

# Generate squid zone file
cp result/squid-whitelist-zones.conf /etc/squid/conf.d/DEFAULT

iptables -F zbrnhlpvpnwhitelist

#echo "" > result/ferm-whitelist-blocked-ranges.conf
#echo "# dummy file. Filled by zaboronahelp script." >> result/ferm-whitelist-blocked-ranges.conf
#echo "@def $WHITELIST = (" >> result/ferm-whitelist-blocked-ranges.conf

# Generate ferm file
cp config/squid-whitelist-zones.conf result/ferm-whitelist-blocked-ranges.conf

while read -r line
do
    iptables -w -A zbrnhlpvpnwhitelist -d "$line" -j ACCEPT
    echo "$line" >> result/ferm-whitelist-blocked-ranges.conf

done < result/blocked-ranges.txt

echo ");" >> result/ferm-whitelist-blocked-ranges.conf

cp result/ferm-whitelist-blocked-ranges.conf /etc/ferm/whitelist.conf
#systemctl restart ferm

exit 0
