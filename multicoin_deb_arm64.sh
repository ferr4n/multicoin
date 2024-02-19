#!/bin/bash
#
# Multicoin Installation Script
# TraffMonetizer, HoneyGain, EarnApp, Pawns/IPRoyal, PacketStream, RePocket, Proxyrack, ProxyLite, Mysterium, EarnFM and BitPing (Meson and Streamr will be included too, MASQ and Grass will be next)
# Versión: 1.0
# Version: 1.0
# License: GPLv3
#

# Log file can be specified here
LOG=/var/log/multicoin.log

# Uncomment to log all the commands:
#exec 1> >(tee $LOG) 2>&1

#echo "Install (or reinstall) and uninstall apps TraffMonetizer, HoneyGain, EarnApp, Pawns/IPRoyal, PacketStream, RePocket, Proxyrack, ProxyLite, Mysterium, EarnFM, Filecoin Station, Meson, Streamr and BitPing"
echo "Install (or reinstall) and uninstall apps TraffMonetizer, HoneyGain, EarnApp, Pawns/IPRoyal, PacketStream, RePocket, Proxyrack, ProxyLite, Mysterium, EarnFM, Filecoin Station and BitPing"
echo
echo "Write a name for this system (without spaces, tipically the hostname) and press enter:"
read nombre
ident=$(cat /etc/hostname)
if [[ $nombre == "" ]]; then
 echo The name cannot be blank, please launch the script again.
 exit 0
fi

## Update system and install security tools
echo
echo "Do you want to update system packages? (Recommended at first execution of the script) [yes/NO] :"
read actapt
actaptmin=$(echo $actapt | tr '[:upper:]' '[:lower:]')
if [[ $actaptmin = "yes" ]]; then
 echo Updating system with apt, this may take a while...
 apt update >> $LOG 2>&1
 apt --purge full-upgrade -y >> $LOG 2>&1
 apt --purge autoremove -y >> $LOG 2>&1
 if [ ! -e /etc/apt/sources.list.d/docker.list ]; then
  echo "Installing Docker (official) and Curl (required by official docker)"
  apt install -y curl >> $LOG 2>&1
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && echo "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >> $LOG 2>&1
  apt install -y --no-install-recommends docker-ce >> $LOG 2>&1
  systemctl enable docker >> $LOG 2>&1
  systemctl restart docker >> $LOG 2>&1
 fi
 apt install -y unattended-upgrades fail2ban needrestart >> $LOG 2>&1
 apt --purge autoremove -y >> $LOG 2>&1
 apt clean >> $LOG 2>&1
 echo Done.
fi

## List currently installed apps
echo
echo Currently installed apps:
echo
# Uncomment for Streamr (expert):
#APPS=`docker ps -a --format '{{.Names}}' | grep 'traffmonetizer\|honeygain\|pawns\|packetstream\|repocket\|proxyrack\|proxylite\|mysterium\|earnfm\|fstation\|streamr\|bitping' | tee /dev/tty`
APPS=`docker ps -a --format '{{.Names}}' | grep 'traffmonetizer\|honeygain\|pawns\|packetstream\|repocket\|proxyrack\|proxylite\|mysterium\|earnfm\|fstation\|bitping' | tee /dev/tty`
# Uncomment for Meson (expert):
#APPS+=" "`ps axco command|grep meson_cdn|sort -u | tee /dev/tty`
APPS+=" "`ps axco command|grep earnapp|sort -u | tee /dev/tty`
# Uncomment for Meson (expert):
#if [[ "$APPS" = "  " ]]; then
if [[ "$APPS" = " " ]]; then
 echo No installed apps yet.
fi

## TraffMonetizer
echo
if [[ "$APPS" =~ .*"traffmonetizer".* ]]; then
 echo "TraffMonetizer was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install TraffMonetizer? [yes/NO] :"
fi
read instm
instmmin=$(echo $instm | tr '[:upper:]' '[:lower:]')
if [[ $instmmin = "yes" ]]; then
 echo Please create an account here: https://traffmonetizer.com/?aff=1042706
 echo "Please paste Your Application Token (shown after logging in) and press enter:"
 read tokentm
 if [[ $tokentm == "" ]]; then
  echo The token cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image traffmonetizer with the token $tokentm and its updater watchtowerTM...
 docker stop traffmonetizer >> $LOG 2>&1
 docker rm traffmonetizer >> $LOG 2>&1
 docker run -d --restart unless-stopped --name traffmonetizer traffmonetizer/cli_v2:arm64v8 start accept --token $tokentm >> $LOG 2>&1
 docker stop watchtowerTM >> $LOG 2>&1
 docker rm watchtowerTM >> $LOG 2>&1
 docker run -d --name watchtowerTM --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower traffmonetizer watchtowerTM --cleanup --include-stopped --include-restarting --revive-stopped --interval 86400 --scope traffmonetizer >> $LOG 2>&1
 echo Done.
else
 if [[ "$APPS" =~ .*"traffmonetizer".* ]]; then
  echo "Do you want to completely remove TraffMonetizer? [yes/NO] :"
  read desinstm
  desinstmmin=$(echo $desinstm | tr '[:upper:]' '[:lower:]')
  if [[ $desinstmmin = "yes" ]]; then
   echo Uninstalling docker image traffmonetizer and its updater watchtowerTM...
   docker stop traffmonetizer >> $LOG 2>&1
   docker rm traffmonetizer >> $LOG 2>&1
   docker rmi traffmonetizer/cli_v2:arm64v8  >> $LOG 2>&1
   docker stop watchtowerTM >> $LOG 2>&1
   docker rm watchtowerTM >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## HoneyGain
echo
if [[ "$APPS" =~ .*"honeygain".* ]]; then
 echo "HoneyGain was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install HoneyGain? [yes/NO] :"
fi
read inshg
inshgmin=$(echo $inshg | tr '[:upper:]' '[:lower:]')
if [[ $inshgmin = "yes" ]]; then
 echo Please create an account here: https://r.honeygain.me/FRANS5CAB4
 echo Account email:
 read emailhg
 if [[ $emailhg == "" ]]; then
  echo Email cannot be blank, please launch the script again.
  exit 0
 fi
 echo Account password:
 read passhg
 if [[ $passhg == "" ]]; then
  echo Password cannot be blank, please launch the script again.
  exit 0
 fi
 nombremin=$(echo $nombre | tr '[:upper:]' '[:lower:]')
 echo Installing docker image honeygain with email $emailhg and password $passhg and its updater watchtowerHG...
 cp -a /etc/rc.local /etc/rc.local.ORIG >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64  >> $LOG 2>&1
 docker stop honeygain >> $LOG 2>&1
 docker rm honeygain >> $LOG 2>&1
 docker run -d --restart unless-stopped --platform linux/amd64 --name honeygain honeygain/honeygain -tou-accept -email $emailhg -pass $passhg -device $nombremin >> $LOG 2>&1
 docker stop watchtowerHG >> $LOG 2>&1
 docker rm watchtowerHG >> $LOG 2>&1
 docker run -d --name watchtowerHG --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower honeygain watchtowerHG --scope honeygain --interval 86410 >> $LOG 2>&1
 echo Done.
else
 if [[ "$APPS" =~ .*"honeygain".* ]]; then
  echo "Do you want to completely remove HoneyGain? [yes/NO] :"
  read desinshg
  desinshgmin=$(echo $desinshg | tr '[:upper:]' '[:lower:]')
  if [[ $desinshgmin = "yes" ]]; then
   echo Uninstalling docker image honeygain and its updater watchtowerHG...
   docker stop honeygain >> $LOG 2>&1
   docker rm honeygain >> $LOG 2>&1
   docker rmi honeygain/honeygain >> $LOG 2>&1
   docker stop watchtowerHG >> $LOG 2>&1
   docker rm watchtowerHG >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## ProxyLite
echo
if [[ "$APPS" =~ .*"proxylite".* ]]; then
 echo "ProxyLite was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install ProxyLite? [yes/NO] :"
fi
read inspl
insplmin=$(echo $inspl | tr '[:upper:]' '[:lower:]')
if [[ $insplmin = "yes" ]]; then
 echo Please create an account here: https://proxylite.ru/?r=VXCFMG4X
 echo User ID:
 read idpl
 if [[ $idpl == "" ]]; then
  echo User ID cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image proxylite with ID $idpl and its updater watchtowerPL...
 cp -a /etc/rc.local /etc/rc.local.ORIG >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64  >> $LOG 2>&1
 docker stop proxylite  >> $LOG 2>&1
 docker rm proxylite  >> $LOG 2>&1
 docker run -de "USER_ID=$idpl" --restart unless-stopped --platform linux/amd64 --name proxylite proxylite/proxyservice >> $LOG 2>&1
 docker stop watchtowerPL  >> $LOG 2>&1
 docker rm watchtowerPL  >> $LOG 2>&1
 docker run -d --name watchtowerPL --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower proxylite watchtowerPL --cleanup --include-stopped --include-restarting --revive-stopped  --scope proxylite --interval 86420  >> $LOG 2>&1
 echo Done.
else
 if [[ "$APPS" =~ .*"proxylite".* ]]; then
  echo "Do you want to completely remove ProxyLite? [yes/NO] :"
  read desinspl
  desinsplmin=$(echo $desinspl | tr '[:upper:]' '[:lower:]')
  if [[ $desinsplmin = "yes" ]]; then
   echo Uninstalling docker image proxylite and its updater watchtowerPL...
   docker stop proxylite >> $LOG 2>&1
   docker rm proxylite >> $LOG 2>&1
   docker rmi proxylite/proxyservice >> $LOG 2>&1
   docker stop watchtowerPL >> $LOG 2>&1
   docker rm watchtowerPL >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## EarnApp
echo
if [[ "$APPS" =~ .*"earnapp".* ]]; then
 echo "EarnApp was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install EarnApp? [yes/NO] :"
fi
read insea
inseamin=$(echo $insea | tr '[:upper:]' '[:lower:]')
if [[ $inseamin = "yes" ]]; then
 echo Please create an account here: https://earnapp.com/i/zJDVLbf9
 echo When it is done press enter to continue.
 read continuar
 echo "Installing native earnapp app (there is no docker image)..."
 if [ -e /usr/bin/earnapp ]; then
  earnapp uninstall
 fi
 wget -qO- https://brightdata.com/static/earnapp/install.sh > /tmp/earnapp.sh
 bash /tmp/earnapp.sh
 echo Done.
 echo IMPORTANTE:
 echo Copy the link above and paste it to the address bar of the browser logged in earnapp.
 echo When it is done press enter to continue.
 read continuar
else
 if [[ "$APPS" =~ .*"earnapp".* ]]; then
  echo "Do you want to completely remove EarnApp? [yes/NO] :"
  read desinsea
  desinseamin=$(echo $desinsea | tr '[:upper:]' '[:lower:]')
  if [[ $desinseamin = "yes" ]]; then
   echo Uninstalling EarnApp...
   earnapp uninstall
   echo Done.
  fi
 fi
fi

## Pawns/IR
echo
if [[ "$APPS" =~ .*"pawns".* ]]; then
 echo "Pawns - IP Royal was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install Pawns - IP Royal? [yes/NO] :"
fi
read inspawns
inspawnsmin=$(echo $inspawns | tr '[:upper:]' '[:lower:]')
if [[ $inspawnsmin = "yes" ]]; then
 echo Please create an account here: https://pawns.app?r=1262397
 echo Account email:
 read emailpawns
 if [[ $emailpawns == "" ]]; then
  echo Email cannot be blank, please launch the script again.
  exit 0
 fi
 echo Account password:
 read passpawns
 if [[ $passpawns == "" ]]; then
  echo Password cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image pawns with email $emailpawns and password $passpawns and its updater watchtowerPawns...
 docker stop pawns >> $LOG 2>&1
 docker rm pawns >> $LOG 2>&1
 docker run -d --restart unless-stopped --name pawns iproyal/pawns-cli:latest -email=$emailpawns -password=$passpawns -device-name=$nombre -device-id=$ident -accept-tos >> $LOG 2>&1
 docker stop watchtowerPawns >> $LOG 2>&1
 docker rm watchtowerPawns >> $LOG 2>&1
 docker run -d --name watchtowerPawns --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower pawns watchtowerPawns --cleanup --include-stopped --include-restarting --revive-stopped --interval 86430 --scope pawns >> $LOG 2>&1
 echo Done.
else
 echo "Do you want to completely remove Pawns - IP Royal? [yes/NO] :"
 read desinspawns
 desinspawnsmin=$(echo $desinspawns | tr '[:upper:]' '[:lower:]')
 if [[ $desinspawnsmin = "yes" ]]; then
  echo Uninstalling docker image pawns and its updater watchtowerPawns...
  docker stop pawns >> $LOG 2>&1
  docker rm pawns >> $LOG 2>&1
  docker rmi iproyal/pawns-cli:latest >> $LOG 2>&1
  docker stop watchtowerPawns >> $LOG 2>&1
  docker rm watchtowerPawns >> $LOG 2>&1
  echo Done.
 fi
fi

## PacketStream
echo
if [[ "$APPS" =~ .*"packetstream".* ]]; then
 echo "PacketStream was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install PacketStream? [yes/NO] :"
fi
read insps
inspsmin=$(echo $insps | tr '[:upper:]' '[:lower:]')
if [[ $inspsmin = "yes" ]]; then
 echo Please create an account here: https://packetstream.io/?psr=4tx2
 echo "Insert your CID (it can be found in https://packetstream.io/dashboard/download when logged in, in the instructions for Linux: look for CID=) :"
 read cidps
 if [[ $cidps == "" ]]; then
  echo CID cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image packetstream with CID $cidps and its updater watchtowerPS...
 docker stop packetstream >> $LOG 2>&1
 docker rm packetstream >> $LOG 2>&1
 docker run -de CID=$cidps --restart unless-stopped --platform linux/arm64 --name packetstream packetstream/psclient:latest >> $LOG 2>&1
 docker stop watchtowerPS >> $LOG 2>&1
 docker rm watchtowerPS >> $LOG 2>&1
 docker run -d --restart unless-stopped --name watchtowerPS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower packetstream watchtowerPS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86440 --scope packetstream >> $LOG 2>&1
 echo Done.
else
 if [[ "$APPS" =~ .*"packetstream".* ]]; then
  echo "Do you want to completely remove PacketStream? [yes/NO] :"
  read desinsps
  desinspsmin=$(echo $desinsps | tr '[:upper:]' '[:lower:]')
  if [[ $desinspsmin = "yes" ]]; then 
   echo Uninstalling docker image packetstream and its updater watchtowerPS...
   docker stop packetstream >> $LOG 2>&1
   docker rm packetstream >> $LOG 2>&1
   docker rmi packetstream/psclient:latest >> $LOG 2>&1
   docker stop watchtowerPS >> $LOG 2>&1
   docker rm watchtowerPS >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## RePocket
echo
if [[ "$APPS" =~ .*"repocket".* ]]; then
 echo "RePocket was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install RePocket? [yes/NO] :"
fi
read insrp
insrpmin=$(echo $insrp | tr '[:upper:]' '[:lower:]')
if [[ $insrpmin = "yes" ]]; then
 echo Please create an account here: https://link.repocket.co/N6up
 echo Account email:
 read emailrp
 if [[ $emailrp == "" ]]; then
  echo Email cannot be blank, please launch the script again.
  exit 0
 fi
 echo "Paste the API key that is shown when logged in the web page and press enter:"
 read apirp
 if [[ $apirp == "" ]]; then
  echo API key cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image repocket con el email $emailrp and API key $apirp and its updater watchtowerRP...
 docker stop repocket >> $LOG 2>&1
 docker rm repocket >> $LOG 2>&1
 docker run -d -e RP_EMAIL=$emailrp -e RP_API_KEY=$apirp --restart unless-stopped --name repocket repocket/repocket >> $LOG 2>&1
 docker stop watchtowerRP >> $LOG 2>&1
 docker rm watchtowerRP >> $LOG 2>&1
 docker run -d --restart unless-stopped --name watchtowerRP -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower repocket watchtowerRP --cleanup --include-stopped --include-restarting --revive-stopped --interval 86450 --scope repocket >> $LOG 2>&1
 echo Done.
else
 if [[ "$APPS" =~ .*"repocket".* ]]; then
  echo "Do you want to completely remove RePocket? [yes/NO] :"
  read desinsrp
  desinsrpmin=$(echo $desinsrp | tr '[:upper:]' '[:lower:]')
  if [[ $desinrpsmin = "yes" ]]; then
   echo Uninstalling docker image repocket and its updater watchtowerRP...
   docker stop repocket >> $LOG 2>&1
   docker rm repocket >> $LOG 2>&1
   docker rmi repocket/repocket >> $LOG 2>&1
   docker stop watchtowerRP >> $LOG 2>&1
   docker rm watchtowerRP >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## ProxyRack:
echo
if [[ "$APPS" =~ .*"proxyrack".* ]]; then
 echo "ProxyRack was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install ProxyRack? [yes/NO] :"
fi
read inspr
insprmin=$(echo $inspr | tr '[:upper:]' '[:lower:]')
if [[ $insprmin = "yes" ]]; then
 echo Please create an account here: https://peer.proxyrack.com/ref/zc9zfiz8nlp8of0mk2mujzbll9iv8sd85vvepfdg
 echo When it is done press enter to continue.
 read continuar
 echo Installing docker image proxyrack and its updater watchtowerPR...
 cp -a /etc/rc.local /etc/rc.local.BACK.PR >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm  tonistiigi/binfmt --install amd64' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK > $LOG  2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64 >> $LOG 2>&1
 docker stop proxyrack >> $LOG 2>&1
 docker rm proxyrack >> $LOG 2>&1
 cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null > UUID_PR.txt
 export UUID_PR=`cat UUID_PR.txt`
 docker run -de UUID="$UUID_PR" --restart unless-stopped --platform linux/amd64 --name proxyrack --restart unless-stopped proxyrack/pop >> $LOG 2>&1
 docker stop watchtowerPR >> $LOG 2>&1
 docker rm watchtowerPR >> $LOG 2>&1
 docker run -d --restart unless-stopped --name watchtowerPR -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower proxyrack watchtowerPR --cleanup --include-stopped --include-restarting --revive-stopped --interval 86460 --scope proxyrack >> $LOG 2>&1
 echo ProxyRack instalado.
 echo IMPORTANTE. Dar de alta el dispositivo $nombre con el ID $UUID_PR en https://peer.proxyrack.com/devices
else
 if [[ "$APPS" =~ .*"proxyrack".* ]]; then
  echo "Do you want to completely remove ProxyRack? [yes/NO] :"
  read desinspr
  desinsprmin=$(echo $desinspr | tr '[:upper:]' '[:lower:]')
  if [[ $desinsprmin = "yes" ]]; then
   echo Uninstalling docker image proxyrack and its updater watchtowerPR... 
   docker stop proxyrack >> $LOG 2>&1
   docker rm proxyrack >> $LOG 2>&1
   docker rmi proxyrack/pop >> $LOG 2>&1
   docker stop watchtowerPR >> $LOG 2>&1
   docker rm watchtowerPR >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## Mysterium
echo
if [[ "$APPS" =~ .*"mysterium".* ]]; then
 echo "Mysterium was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install Mysterium? [yes/NO] :"
fi
read insmy
insmymin=$(echo $insmy | tr '[:upper:]' '[:lower:]')
if [[ $insmymin = "yes" ]]; then
 echo Please create an account here: https://mystnodes.co/?referral_code=qs4DTlbdhLyEsK0QFFVZYZlsY1MRBrbajZqXhZGc
 echo When it is done press enter to continue.
 read continuar
 echo Installing docker image mysterium and its updater watchtowerMyst...
 docker stop mysterium >> $LOG 2>&1
 docker rm mysterium >> $LOG 2&1
 docker run -d --cap-add NET_ADMIN -d -p 4449:4449 --name mysterium -v myst-data:/var/lib/mysterium-node --restart unless-stopped mysteriumnetwork/myst:latest service --agreed-terms-and-conditions >> $LOG 2>&1
 docker stop watchtowerMyst >> $LOG 2>&1
 docker rm watchtowerMyst >> $LOG 2>&1
 docker run -d --name watchtowerMyst --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower mysterium watchtowerMyst --cleanup --include-stopped --include-restarting --revive-stopped --interval 86470 --scope mysterium >> $LOG 2>&1
 echo IMPORTANT: Mysterium needs activation from its dashboard in http://LOCAL-IP:4449. It will prompt for your API key shown on mystnodes.com
 echo In order to avoid forwarding ports or activating UPnP on the router enter Settings, Advanced in the dashboard and place HolePunching to the first place, on top.
 echo When it is done press enter to continue.
 read continuar
 echo Done.
else
 if [[ "$APPS" =~ .*"mysterium".* ]]; then
  echo "Do you want to completely remove Mysterium? [yes/NO] :"
  read desinsmy
  desinsmymin=$(echo $desinsmy | tr '[:upper:]' '[:lower:]')
  if [[ $desinsmymin = "yes" ]]; then
   echo Uninstalling docker image mysterium and its updater watchtowerMyst...
   docker stop mysterium >> $LOG 2>&1
   docker rm mysterium >> $LOG 2>&1
   docker rmi mysteriumnetwork/myst:latest >> $LOG 2>&1
   docker stop watchtowerMyst >> $LOG 2>&1
   docker rm watchtowerMyst >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## EarnFM
echo
if [[ "$APPS" =~ .*"earnfm".* ]]; then
 echo "EarnFM was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install EarnFM? [yes/NO] :"
fi
read insef
insefmin=$(echo $insef | tr '[:upper:]' '[:lower:]')
if [[ $insefmin = "yes" ]]; then
 echo Please create an account here: https://earn.fm/ref/FRAN6E6B
 echo When it is done paste your API Key and press enter to continue.
 read efapi
 echo Installing docker image earnfm and its updater watchtowerEF...
 docker stop earnfm >> $LOG 2>&1
 docker rm earnfm >> $LOG 2>&1
 docker run -de EARNFM_TOKEN="$efapi" --restart unless-stopped --name earnfm earnfm/earnfm-client:latest >> $LOG 2>&1
 docker stop watchtowerEF >> $LOG 2>&1
 docker rm watchtowerEF >> $LOG 2>&1
 docker run -d --restart unless-stopped --name watchtowerEF -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower earnfm watchtowerEF --cleanup --include-stopped --include-restarting --revive-stopped --interval 86480 --scope earnfm >> $LOG 2>&1
 echo Done.
else
 if [[ "$APPS" =~ .*"earnfm".* ]]; then
  echo "Do you want to completely remove EarnFM? [yes/NO] :"
  read desinsef
  desinsefmin=$(echo $desinsef | tr '[:upper:]' '[:lower:]')
  if [[ $desinsefmin = "yes" ]]; then
   echo Uninstalling docker image earnfm and its updater watchtowerEF...
   docker stop earnfm >> $LOG 2>&1
   docker rm earnfm >> $LOG 2>&1
   docker rmi earnfm/earnfm-client:latest >> $LOG 2>&1
   docker stop watchtowerEF >> $LOG 2>&1
   docker rm watchtowerEF >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## Filecoin Station
echo
if [[ "$APPS" =~ .*"fstation".* ]]; then
 echo "Filecoin Station was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
else
 echo "Do you want to install Filecoin Station? [yes/NO] :"
fi
read insfs
insfsmin=$(echo $insfs | tr '[:upper:]' '[:lower:]')
if [[ $insfsmin = "si" ]]; then
 echo You need to have the token FIL in the Polygon network of your Ethereum wallet, it can be done in chainlist.org
 echo When it is done paste your wallet address and press enter to continue.
 read fswallet
 echo Installing docker image fstation and its updater watchtowerFS...
 docker stop fstation >> $LOG 2>&1
 docker rm fstation >> $LOG 2>&1
 docker run -de FIL_WALLET_ADDRESS="$fswallet" --restart unless-stopped --name fstation ghcr.io/filecoin-station/core >> $LOG 2>&1
 docker stop watchtowerFS >> $LOG 2>&1
 docker rm watchtowerFS >> $LOG 2>&1
 docker run -d --restart unless-stopped --name watchtowerFS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower fstation watchtowerFS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86490 --scope fstation >> $LOG 2>&1
 echo Filecoin Station instalado.
else
 if [[ "$APPS" =~ .*"fstation".* ]]; then
  echo "Do you want to completely remove Filecoin Station? [yes/NO] :"
  read desinsfs
  desinsfsmin=$(echo $desinsfs | tr '[:upper:]' '[:lower:]')
  if [[ $desinsfsmin = "si" ]]; then
   echo Uninstalling docker image fstation and its updater watchtowerFS...
   docker stop fstation >> $LOG 2>&1
   docker rm fstation >> $LOG 2>&1
   docker rmi ghcr.io/filecoin-station/core >> $LOG 2>&1
   docker stop watchtowerFS >> $LOG 2>&1
   docker rm watchtowerFS >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## Meson: NOT INSTALLED BECAUSE THE PROJECT IS IN BETA STAGE
#echo
#if [ -e /usr/bin/earnapp ]; then
# echo Meson was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
#else
# echo "Do you want to install Meson? [yes/NO] :"
#fi
#read insms
#insmsmin=$(echo $insms | tr '[:upper:]' '[:lower:]')
#if [[ $insmsmin = "yes" ]]; then
# echo Please create an account here: https://dashboard.meson.network/register
# echo Please paste your token, shown in https://dashboard.meson.network/user/account and press enter :
# read tokenms
# if [[ $tokenms == "" ]]; then
#  echo Token cannot be blank, please launch the script again.
#  exit 0
# fi
# echo "Meson needs a TCP port forwarded, it is 448 by default, you can specify another if you wish [448]:"
# read portms
# if [[ $portms == "" ]]; then
#  portms=448
# fi
# echo "Installing native Meson app (there is no docker image), with token $tokenms and port $portms ..."
# /root/meson_cdn-linux-arm64/service stop meson_cdn >> $LOG 2>&1
# /root/meson_cdn-linux-arm64/service remove meson_cdn >> $LOG 2>&1
# rm -rf /root/meson_cdn-linux-arm64
# cd /root/ >> $LOG 2>&1
# wget 'https://staticassets.meson.network/public/meson_cdn/v3.1.20/meson_cdn-linux-arm64.tar.gz' >> $LOG 2>&1
# tar -zxf meson_cdn-linux-arm64.tar.gz >> $LOG 2>&1
# rm -f /root/meson_cdn-linux-arm64.tar.gz >> $LOG 2>&1
# /root/meson_cdn-linux-arm64/service install meson_cdn >> $LOG 2>&1
# /root/meson_cdn-linux-arm64/meson_cdn config set --token=$tokenms --https_port=$portms --cache.size=30 >> $LOG 2>&1
# /root/meson_cdn-linux-arm64/service start meson_cdn >> $LOG 2>&1
# echo Done.
# echo IMPORTANT: Do not forget to open TCP PORT $portms in your router, forwarding it to the LOCAL IP of this device.
#else
# echo "Do you want to completely remove Meson? [yes/NO] :"
# read desinsms
# desinsmsmin=$(echo $desinsms | tr '[:upper:]' '[:lower:]')
# if [[ $desinsmsmin = "yes" ]]; then
#  echo Uninstalling Meson...
#  /root/meson_cdn-linux-arm64/service stop meson_cdn >> $LOG 2>&1
#  /root/meson_cdn-linux-arm64/service remove meson_cdn >> $LOG 2>&1
#  rm -rf /root/meson_cdn-linux-arm64
#  echo Done.
# fi
#fi

## Streamr: NOT INSTALLED BECAUSE THE PROJECT IS IN BETA STAGE
## NOT TRANSLATED FOR THE SAME REASON, IF YOU WANT TO INSTALL IT JUST USE dee.pl OR ANY OTHER TRANSLATOR
#echo
#if [[ "$APPS" =~ .*"streamr".* ]]; then
# echo "Streamr ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
#else
# echo "¿Quiere instalar Streamr? [si/NO] :"
#fi
#read inss
#inssmin=$(echo $inss | tr '[:upper:]' '[:lower:]')
#if [[ $inssmin = "si" ]]; then
# echo Es necesario tener una dirección IP pública y un puerto TCP abierto (por defecto es el 32200)
# echo "Escriba el puerto que desea utilizar [32200] :"
# read sport
# if [[ $sport == "" ]]; then
#  sports=32200
# fi
# echo "Por favor siga las instrucciones en pantalla para inicializar al app Streamr."
# echo "Si tiene una billetera Ethereum puede desea usarla con Streamr, pero le recomendamos generar una."
# echo "Si quiere recibir recompensas escoja Streamr 1.0 testnet + Polygon (en vez de Mumbai)"
# echo "Aquí tiene la documentación sobre los Sponsorships (patrocinios): https://docs.streamr.network/streamr-network/incentives/stream-sponsorships"
# echo "Para tener una dirección de operador (Operator Address) es necesario conectar su billetera en https://streamr.network/hub/network/operators"
# echo "Una vez hecho eso pulsamos en Become an Operator, recomendamos poner 10% en Owner's cut percentage y dejar el factor de redundancia en 2"
# echo "Cuando haya puesto resto de datos y aceptado cambiar a la red Polygon y pagado la comisión del contrato puede ver su dirección en el centro de la pantalla, después de Operator:"
# echo "Recomendamos aceptar el uso del nodo para la publicación/suscripción de datos"
# echo "Recomendamos seleccionar el plugin: Websocket por ser el más avanzado y el configurado en docker,"
# echo "aunque puede seleccionar más de uno (si ve símbolos <?> para seleccionarlo solo tiene que tener un símbolo)."
# echo "Necesita un puerto TCP/UDP abierto por cada plugin que escoja."
# docker stop streamr >> $LOG 2>&1
# docker rm streamr >> $LOG 2>&1
# mkdir -p /root/.streamrDocker && chmod 777 /root/.streamrDocker
# docker run -it -v /root/.streamrDocker:/home/streamr/.streamr streamr/broker-node:v100.0.0-testnet-three.3 bin/config-wizard
# echo "A continuación tiene que enviar un poco de MATIC a la dirección del nodo (por ejemplo 0.1)"
# echo "Y finalmente tiene que añadir el nodo en su página de operador, por la parte inferior encontrará la sección: Operator's node addresses"
# echo "Solo tiene que pulsar en el botón Add node address y pegar la dirección del nodo recién creado."
# echp "Pulse enter cuando haya finalizado, para proceder a la ejecución del nodo Streamr"
# echo "Activando la imagen de docker streamr y el actualizador watchtowerS..."
# docker run -d -p "$sport":32200 --name streamr --restart unless-stopped -v /root/.streamrDocker:/home/streamr/.streamr streamr/broker-node:v100.0.0-testnet-three.3
# docker stop watchtowerS >> $LOG 2>&1
# docker rm watchtowerS >> $LOG 2>&1
# docker run -d --restart unless-stopped --name watchtowerS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower streamr watchtowerS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86510 --scope streamr >> $LOG 2>&1
# echo Streamr instalado.
#else
# if [[ "$APPS" =~ .*"streamr".* ]]; then
#  echo "¿Quiere eliminar completamente Streamr? [si/NO] :"
#  read desinss
#  desinssmin=$(echo $desinss | tr '[:upper:]' '[:lower:]')
#  if [[ $desinssmin = "si" ]]; then
#   echo Desinstalando imagen de docker streamr y actualizador watchtowerS...
#   docker stop streamr >> $LOG 2>&1
#   docker rm streamr >> $LOG 2>&1
#   docker rmi streamr/broker-node:v100.0.0-testnet-three.3 >> $LOG 2>&1
#   docker stop watchtowerS >> $LOG 2>&1
#   docker rm watchtowerS >> $LOG 2>&1
#   echo Streamr desinstalado.
#  fi
# fi
#fi

## BitPing:
echo
if [[ "$APPS" =~ .*"bitping".* ]]; then
 echo "BitPing was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install BitPing? [yes/NO] :"
fi
read insbp
insbpmin=$(echo $insbp | tr '[:upper:]' '[:lower:]')
if [[ $insbpmin = "yes" ]]; then
 echo Please create an account here: https://app.bitping.com?r=hxQvBwhm
 echo When it is done press enter to continue.
 read continuar
 echo Installing docker image bitping and its updater watchtowerBP...
 cp -a /etc/rc.local /etc/rc.local.BACK.BP >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64  >> $LOG 2>&1
 docker stop watchtowerBP >> $LOG 2>&1
 docker rm watchtowerBP >> $LOG 2>&1
 docker run -d --restart unless-stopped --name watchtowerBP -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower bitping watchtowerBP --cleanup --include-stopped --include-restarting --revive-stopped --interval 86500 --scope bitping >> $LOG 2>&1
 docker stop bitping >> $LOG 2>&1
 docker rm bitping >> $LOG 2>&1
 echo IMPORTANT:
 echo "This is the last app, we have placed it here because the process is a bit more difficult:"
 echo When asked by the app, insert the account email and password.
 echo Press CTRL+C as soon as you see \'Successfully logged in to Bitping\'
 echo After the app closes please paste the following command and press enter:
 echo
 echo 'docker stop bitping; docker rm bitping; docker run -d --restart unless-stopped --platform linux/amd64 --name bitping -it --mount type=bind,source="/root/bitping/",target=/root/.bitping bitping/bitping-node:latest; echo Done.'
 echo
 echo Once you have copied the command above please press enter to proceed as explained.
 read continuar
 mkdir -p /root/bitping
 docker run --restart unless-stopped --platform linux/amd64 --name bitping -it --mount type=bind,source="/root/bitping/",target=/root/.bitping bitping/bitping-node:latest
else
 if [[ "$APPS" =~ .*"bitping".* ]]; then
  echo "Do you want to completely remove BitPing? [yes/NO] :"
  read desinsbp
  desinsbpmin=$(echo $desinsbp | tr '[:upper:]' '[:lower:]')
  if [[ $desinsbpmin = "yes" ]]; then
   echo Uninstalling docker image bitping and its updater watchtowerBP...
   docker stop bitping >> $LOG 2>&1
   docker rm bitping >> $LOG 2>&1
   docker rmi bitping/bitping-node:latest >> $LOG 2>&1
   docker stop watchtowerBP >> $LOG 2>&1
   docker rm watchtowerBP >> $LOG 2>&1
   echo Done.
  fi
 fi
fi
