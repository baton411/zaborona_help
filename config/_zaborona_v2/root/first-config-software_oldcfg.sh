#!/bin/sh

# Checking root privileges
if [ "$(id -u)" -ne 0 ]
  then echo "Please run as root or use sudo"
  exit 1
fi

# Stop script on errors
#set -e

HERE="$(dirname "$(readlink -f "${0}")")"
cd "$HERE"

# Full path to the current directory ( Полный путь до текущей директории )
$PWD

# Get hostname
HOSTNAME="$(hostname)"

# Get master interface name
MASTERIF="$(ls /sys/class/net | awk '{print $1}' | head -n 1)"

# Проверяем, существует ли файл конфига dnsmasq либо knot-resolver
if [ -f /etc/dnsmasq.conf ]
then
	$dnsserver="dnsmasq"
elif [ -f /etc/knot-resolver/kresd.conf ]
	$dnsserver="knot-resolver"
else
	echo "!!! Не установлен ДНС сервер dnsmasq либо knot-resolver. Некуда копировать конфигурационные файлы."
fi

# Проверяем, существует ли файл конфига ferm
if [ -f /etc/ferm/ferm.conf ]
then
	$iptablesCTRL="ferm"
fi

### CONFIG FILES ###
LISTLINK_ALLCONFIG_ARCHIVE="https://raw.githubusercontent.com/zhovner/zaborona_help/master/config/_zaborona_v2"
FILENAMEALLCONFIG_ARCHIVE="zaborona-vpn-config-archive0.zip"
FILENAMEALLCONFIG_ARCHIVE_MD5="zaborona-vpn-config-archive-MD5.zip"
WORKFOLDERNAME=$PWD
TMPFOLDERNAME="/tmp"
#MD51="$(md5sum $WORKFOLDERNAME/$FILENAMEALLCONFIG_ARCHIVE | awk '{print $1}')"
#MD52="$(md5sum $WORKFOLDERNAME/$FILENAMEALLCONFIG_ARCHIVE_MD5 | awk '{print $1}')"

#curl -f --fail-early --compressed --connect-timeout 15 -o $WORKFOLDERNAME/$FILENAMEALLCONFIG_ARCHIVE "$LISTLINK_ALLCONFIG_ARCHIVE/$FILENAMEALLCONFIG_ARCHIVE" || exit 1

if  curl -f --fail-early --compressed --connect-timeout 15 -o $WORKFOLDERNAME/$FILENAMEALLCONFIG_ARCHIVE "$LISTLINK_ALLCONFIG_ARCHIVE/$FILENAMEALLCONFIG_ARCHIVE"; then
    echo "Unpack the archive to the specified folder. Default $PWD"	
    # Распаковываем архив в указанную папку. По-умолчанию $PWD
    #tar xvzf $FILENAMEALLCONFIG_ARCHIVE -C $WORKFOLDERNAME
    unzip -o $WORKFOLDERNAME/$FILENAMEALLCONFIG_ARCHIVE
    cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/root/dnsmap $WORKFOLDERNAME/
    cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/root/easy-rsa-ipsec $WORKFOLDERNAME/
    cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/root/zaborona-vpn $WORKFOLDERNAME/
if [ "$dnsserver" -eq "dnsmasq" ]; then
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/dnsmasq.d/zaborona /etc/dnsmasq.d/zaborona
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/dnsmasq.d/zaborona-dns-resovler /etc/dnsmasq.d/zaborona-dns-resovler
fi
if [ "$dnsserver" -eq "knot-resolver" ]; then
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/knot-resolver/kresd.conf /etc/knot-resolver/kresd.conf
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/knot-resolver/knot-aliases-alt.conf /etc/knot-resolver/knot-aliases-alt.conf
fi
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/sysctl.d/99-openvpn.conf /etc/sysctl.d/99-openvpn.conf
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/sysctl.d/99-swap.conf /etc/sysctl.d/99-swap.conf
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/systemd/system/openvpn-server@.service.d /etc/systemd/system/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/systemd/system/dnsmap.service /etc/systemd/system/dnsmap.service
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/systemd/system/firewall-config-script-custom.service /etc/systemd/system/firewall-config-script-custom.service
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/systemd/system/iperf3.service /etc/systemd/system/iperf3.service
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/*.conf /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/*.crt /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/*.pem /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/logs /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/ccd /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/ccd_zaborona /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/ccd_zaborona_big_routes /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/ccd_zaborona_max_routes /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/openvpn/ccd_zaborona_ru_routes /etc/openvpn/
if [ "$iptablesCTRL" -eq "ferm" ]; then
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/blockport.conf /etc/ferm/blockport.conf
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/blockstring.conf /etc/ferm/blockstring.conf
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/ferm.conf /etc/ferm/ferm.conf
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist.conf /etc/ferm/whitelist.conf
	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist_ipv6.conf /etc/ferm/whitelist_ipv6.conf
#else
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/blockport.conf /etc/ferm/blockport.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/blockstring.conf /etc/ferm/blockstring.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/ferm.conf /etc/ferm/ferm.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist.conf /etc/ferm/whitelist.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist_ipv6.conf /etc/ferm/whitelist_ipv6.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/blockport.conf /etc/ferm/blockport.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/blockstring.conf /etc/ferm/blockstring.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/ferm.conf /etc/ferm/ferm.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist.conf /etc/ferm/whitelist.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist_ipv6.conf /etc/ferm/whitelist_ipv6.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist.conf /etc/ferm/whitelist.conf
#	cp -vR $WORKFOLDERNAME/zaborona_help-master/config/_zaborona_v2/etc/ferm/whitelist_ipv6.conf /etc/ferm/whitelist_ipv6.conf
fi
    rm -r $WORKFOLDERNAME/zaborona_help-master

else

    # If the previous command ended with an error (for example, there is no such file), then download it via git
    # Если предыдущая команда закончилась с ошибкой (например такого файла нет), то скачиваем через git
    #cd $WORKFOLDERNAME && git fetch --all && git reset --hard origin/prod
    git clone https://github.com/zhovner/zaborona_help
    cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/root/dnsmap $WORKFOLDERNAME/
    cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/root/easy-rsa-ipsec $WORKFOLDERNAME/
    cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/root/zaborona-vpn $WORKFOLDERNAME/
if [ "$dnsserver" -eq "dnsmasq" ]; then
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/dnsmasq.d/zaborona /etc/dnsmasq.d/zaborona
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/dnsmasq.d/zaborona-dns-resovler /etc/dnsmasq.d/zaborona-dns-resovler
fi
if [ "$dnsserver" -eq "knot-resolver" ]; then
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/knot-resolver/kresd.conf /etc/knot-resolver/kresd.conf
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/knot-resolver/knot-aliases-alt.conf /etc/knot-resolver/knot-aliases-alt.conf
fi
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/sysctl.d/99-openvpn.conf /etc/sysctl.d/99-openvpn.conf
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/sysctl.d/99-swap.conf /etc/sysctl.d/99-swap.conf
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/systemd/system/openvpn-server@.service.d /etc/systemd/system/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/systemd/system/dnsmap.service /etc/systemd/system/dnsmap.service
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/systemd/system/firewall-config-script-custom.service /etc/systemd/system/firewall-config-script-custom.service
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/systemd/system/iperf3.service /etc/systemd/system/iperf3.service
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/*.conf /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/*.crt /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/*.pem /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/logs /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/ccd /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/ccd_zaborona /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/ccd_zaborona_big_routes /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/ccd_zaborona_max_routes /etc/openvpn/
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/openvpn/ccd_zaborona_ru_routes /etc/openvpn/
if [ "$iptablesCTRL" -eq "ferm" ]; then
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/ferm/blockport.conf /etc/ferm/blockport.conf
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/ferm/blockstring.conf /etc/ferm/blockstring.conf
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/ferm/ferm.conf /etc/ferm/ferm.conf
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/ferm/whitelist.conf /etc/ferm/whitelist.conf
	cp -vR $WORKFOLDERNAME/zaborona_help/config/_zaborona_v2/etc/ferm/whitelist_ipv6.conf /etc/ferm/whitelist_ipv6.conf
else
	cp -vR $WORKFOLDERNAME/zaborona_help/config/iptables.sh $WORKFOLDERNAME/iptables.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaborona.sh $WORKFOLDERNAME/updateCFGzaborona.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaIPTables.sh $WORKFOLDERNAME/updateCFGzaboronaIPTables.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaIPTables.txt $WORKFOLDERNAME/updateCFGzaboronaIPTables.txt
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaIPTablesFREM.sh $WORKFOLDERNAME/updateCFGzaboronaIPTablesFREM.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaIPTablesFREM-ipv6.sh $WORKFOLDERNAME/updateCFGzaboronaIPTablesFREM-ipv6.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaIPTablesWhiteList.sh $WORKFOLDERNAME/updateCFGzaboronaIPTablesWhiteList.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaIPTablesWhiteList.txt $WORKFOLDERNAME/updateCFGzaboronaIPTablesWhiteList.txt
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaIPTablesWhiteListUpdate.sh $WORKFOLDERNAME/updateCFGzaboronaIPTablesWhiteListUpdate.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaOpenVPNRoutesBIG.sh $WORKFOLDERNAME/updateCFGzaboronaOpenVPNRoutesBIG.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaOpenVPNRoutesNEW.sh $WORKFOLDERNAME/updateCFGzaboronaOpenVPNRoutesNEW.sh
	cp -vR $WORKFOLDERNAME/zaborona_help/config/updateCFGzaboronaOpenVPNRoutesOLD.sh $WORKFOLDERNAME/updateCFGzaboronaOpenVPNRoutesOLD.sh
fi
    rm -r $WORKFOLDERNAME/zaborona_help

fi

chmod +x $WORKFOLDERNAME/dnsmap/*.sh
chmod +x $WORKFOLDERNAME/dnsmap/*.py
chmod +x $WORKFOLDERNAME/easy-rsa-ipsec/*.sh
chmod +x $WORKFOLDERNAME/zaborona-vpn/*.sh
chmod +x $WORKFOLDERNAME/zaborona-vpn/config/*.sh
chmod +x $WORKFOLDERNAME/zaborona-vpn/scripts/*.py
chmod +x $WORKFOLDERNAME/*.sh

echo "Edit the netdata config and restart the service"
# Редактируем конфиг netdata и перезапускаем службу
sed -i 's/127.0.0.1/0.0.0.0/' /etc/netdata/netdata.conf
service netdata restart

echo "We re-read the start scripts so that the changes take effect."
# Перечитываем стартовые скрипты, чтобы изменения вступили в силу.
systemctl daemon-reload

echo "We add it to startup and immediately start both OpenVPN processes."
# Добавляем в автозагрузку и сразу стартуем оба процесса OpenVPN.
systemctl enable openvpn@zaborona1
#systemctl enable openvpn@zaborona2
systemctl enable openvpn@zaborona3
#systemctl enable openvpn@zaborona4
systemctl enable openvpn@zaborona5udp
#systemctl enable openvpn@zaborona6udp
systemctl enable openvpn@zaborona7udp
#systemctl enable openvpn@zaborona8udp
systemctl enable openvpn@zaborona12
systemctl enable openvpn@zaborona13udp
echo "!!! Скопировать crt и key !!! Иначе OpenVPN не запустится!"

echo "Enable autostart services"
# Включаем автозапуск сервисов
systemctl enable dnsmap
#systemctl enable firewall-config-script-custom
systemctl enable iperf3

echo "Restart the dnsmasq and ferm services. They are added to startup by default after installation."
# Перезапускаем сервисы dnsmasq либо knot-resolver. Они добавлены в автозагрузку по умолчанию после установки.
if [ "$dnsserver" -eq "dnsmasq" ]; then
systemctl reload dnsmasq
fi
if [ "$dnsserver" -eq "knot-resolver" ]; then
systemctl restart kresd@1.service
fi

# Перезапускаем сервис ferm, если он установлен. Они добавлены в автозагрузку по умолчанию после установки.
if [ "$iptablesCTRL" -eq "ferm" ]; then
systemctl reload ferm

else

sed -i 's/"/root/zaborona-vpn/iptables-custom.sh"/"/root/iptables.sh"/' /etc/systemd/system/firewall-config-script-custom.service

echo "Enable autostart service firewall-config-script-custom"
# Включаем автозапуск сервиса firewall-config-script-custom
systemctl enable firewall-config-script-custom

echo "We get the name of the interface that looks at the Internet, write it in the file and launch the file for execution"
# Получаем имя интерфейса, который смотрит в интернет, прописываем его в файле и запускаем файл на выполнение
sed -i 's/WAN_4="changeIF"/WAN_4="'$MASTERIF'"/' $WORKFOLDERNAME/iptables.sh
sed -i 's/WAN_6="changeIF"/WAN_6="'$MASTERIF'"/' $WORKFOLDERNAME/iptables.sh
$WORKFOLDERNAME/iptables.sh

fi
#

echo "To add it to the crontab, with no duplication"
# Добавления задания в crontab с проверкой дублирования
croncmd="#* * * * * curl -X POST -F 'server=zbrn-srv-$HOSTNAME' http://samp.monitor.example.com/tgbot_take.php"
cronjob="# Check Alive Server\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="0 0 * * * /root/updateCFGzaborona.sh"
cronjob="# Update DNS\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="0 0 * * * /root/updateCFGzaboronaIPTables.sh"
cronjob="# Update IPTables (without restarting ferm)\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="0 0 * * * /root/updateCFGzaboronaIPTablesFREM.sh"
cronjob="# Update FERM IPv4\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="0 0 * * * /root/updateCFGzaboronaIPTablesFREM-ipv6.sh"
cronjob="# Update FERM IPv6\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="0 0 * * * /root/updateCFGzaboronaOpenVPNRoutesNEW.sh"
cronjob="# Update OpenVPN Routes\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="0 0 * * * /root/updateCFGzaboronaOpenVPNRoutesBIG.sh"
cronjob="# Update OpenVPN BIG Routes\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
croncmd="0 0 * * * /root/updateCFGzaboronaIPTablesWhiteListUpdate.sh"
cronjob="# Update IP Address DB\n$croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

echo "We start updating configs after updating files"
# Запускаем обновление конфигов после обновления файлов
#cd "./zaborona-vpn"
#./doall.sh

### CONFIG FILES ###

exit 0