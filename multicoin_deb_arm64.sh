#!/bin/bash
#
# Multicoin Installation Script on Debian ARM64
# TraffMonetizer, HoneyGain, EarnApp, Pawns/IPRoyal, PacketStream, RePocket, Proxyrack, ProxyLite, Mysterium, EarnFM, SpeedShare, Filecoin Station and BitPing.
# Grass, Meson and MASQ* are in Testnet phase without real payments yet.
# Streamr and Presearch* require to invest -or stake- a significant amount to receive rewards.
# *In future versions, also the ones without linux support yet: bytelixir.com/r/Z0FR2SD6FECW , cashraven.io , spider.com , community.theta.tv/theta-edge-node , nodle.com
# Version: 1.5.3
# License: GPLv3
#

# Log file can be specified here
LOG=/var/log/multicoin.log

# Uncomment to log the output of absolutely all the commands (useful for debugging purposes):
#exec 1> >(tee $LOG) 2>&1

# Uncomment for Streamr (expert):
#echo "Install (or reinstall) and uninstall apps TraffMonetizer, HoneyGain, EarnApp, Pawns/IPRoyal, PacketStream, RePocket, Proxyrack, ProxyLite, Mysterium, EarnFM, SpeedShare, Filecoin Station, Grass, Meson, Streamr and BitPing"
echo "Install (or reinstall) and uninstall apps TraffMonetizer, HoneyGain, EarnApp, Pawns/IPRoyal, PacketStream, RePocket, Proxyrack, ProxyLite, Mysterium, EarnFM, SpeedShare, Filecoin Station, Grass, Meson and BitPing"
echo
echo "Write a name for this system (without spaces, tipically the hostname) and press enter:"
read name
ident=$(cat /etc/hostname)
if [[ $name == "" ]]; then
 echo The name cannot be blank, please launch the script again.
 exit 0
fi
ident=$(cat /etc/hostname)

## Update system and install security tools
echo
echo "Do you want to update system packages? (Recommended at first execution of the script) [yes/NO] :"
read actapt
actaptmin=$(echo $actapt | tr '[:upper:]' '[:lower:]')
if [[ $actaptmin = "yes" ]]; then
 if [ ! -e /etc/apt/sources.list.d/docker.list ]; then
  echo "Installing Docker (official) and Curl (required by official docker)"
  apt install -y curl >> $LOG 2>&1
  curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && echo "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >> $LOG 2>&1
  apt update >> $LOG 2>&1
  apt install -y --no-install-recommends --purge docker-ce >> $LOG 2>&1
  systemctl enable docker >> $LOG 2>&1
  systemctl restart docker >> $LOG 2>&1
 fi
if [ ! -e /etc/docker/daemon.json ]; then
 echo Setting limit to docker logs to 10 MB and 3 files...
 cat <<EOF >/etc/docker/daemon.json
{
 "log-driver": "json-file",
 "log-opts":
 {
  "max-size": "10m",
  "max-file": "3"
 }
}
EOF
fi
if [ ! -e /etc/dphys-swapfile ]; then
 echo Inscreasing dphys swap size to 4 GB (max. 8 GB)
 cp -a /etc/dphys-swapfile /etc/dphys-swapfile.ORIG
 cat <<EOF >/etc/dphys-swapfile
CONF_SWAPSIZE=4096
CONF_SWAPFACTOR=4
CONF_MAXSWAP=8192
EOF
fi
 echo Updating packages with apt, this may take a while...
 apt update >> $LOG 2>&1
 apt --purge full-upgrade -y >> $LOG 2>&1
 apt install -y unattended-upgrades fail2ban >> $LOG 2>&1
 apt --purge autoremove -y >> $LOG 2>&1
 apt clean >> $LOG 2>&1
 echo Done.
fi

## List currently installed apps
echo
echo Currently installed apps:
echo
# Uncomment for Streamr (expert):
#APPS=`docker ps -a --format '{{.Names}}' | grep -F -e traffmonetizer -e honeygain -e pawns -e packetstream -e repocket -e proxyrack -e proxylite -e mysterium -e earnfm -e filecoinstation -e bitping -e streamr | tee /dev/tty`
APPS=`docker ps -a --format '{{.Names}}' | grep -F -e traffmonetizer -e honeygain -e pawns -e packetstream -e repocket -e proxyrack -e proxylite -e mysterium -e earnfm -e filecoinstation -e bitping | tee /dev/tty`
APPS+=" "`ps axco command | grep -F -e earnapp -e speedshare -e meson_cdn | sort | uniq | tee /dev/tty`
if [[ "$APPS" = " " ]]; then
 echo No app installed.
fi

## TraffMonetizer
echo
echo "TraffMonetizer: https://traffmonetizer.com/?aff=1042706"
if [[ "$APPS" =~ .*"traffmonetizer".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
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
 echo Installing docker image traffmonetizer with the token $tokentm and its updater updaterTM...
 docker stop traffmonetizer >> $LOG 2>&1
 docker rm traffmonetizer >> $LOG 2>&1
 docker run -d --restart unless-stopped --name traffmonetizer traffmonetizer/cli_v2:arm64v8 start accept --token $tokentm >> $LOG 2>&1
 docker stop updaterTM >> $LOG 2>&1
 docker rm updaterTM >> $LOG 2>&1
 docker run -d --name updaterTM --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower traffmonetizer updaterTM --cleanup --include-stopped --include-restarting --revive-stopped --interval 86400 --scope traffmonetizer >> $LOG 2>&1
 echo TraffMonetizer installed and running.
else
 if [[ "$APPS" =~ .*"traffmonetizer".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinstm
  desinstmmin=$(echo $desinstm | tr '[:upper:]' '[:lower:]')
  if [[ $desinstmmin = "yes" ]]; then
   echo Uninstalling docker image traffmonetizer and its updater updaterTM...
   docker stop traffmonetizer >> $LOG 2>&1
   docker rm traffmonetizer >> $LOG 2>&1
   docker rmi traffmonetizer/cli_v2:arm64v8 >> $LOG 2>&1
   docker stop updaterTM >> $LOG 2>&1
   docker rm updaterTM >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## HoneyGain
echo
echo HoneyGain: https://r.honeygain.me/FRANS5CAB4
if [[ "$APPS" =~ .*"honeygain".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
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
 namemin=$(echo $name | tr '[:upper:]' '[:lower:]')
 echo Installing docker image honeygain with email $emailhg and password $passhg and its updater updaterHG...
 cp -a /etc/rc.local /etc/rc.local.ORIG >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64 &' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64 >> $LOG 2>&1
 docker stop honeygain >> $LOG 2>&1
 docker rm honeygain >> $LOG 2>&1
 docker run -d --restart unless-stopped --platform linux/amd64 --name honeygain honeygain/honeygain -tou-accept -email $emailhg -pass $passhg -device $namemin >> $LOG 2>&1
 docker stop updaterHG >> $LOG 2>&1
 docker rm updaterHG >> $LOG 2>&1
 docker run -d --name updaterHG --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower honeygain updaterHG --scope honeygain --interval 86410 >> $LOG 2>&1
 echo HoneyGain installed and running..
else
 if [[ "$APPS" =~ .*"honeygain".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinshg
  desinshgmin=$(echo $desinshg | tr '[:upper:]' '[:lower:]')
  if [[ $desinshgmin = "yes" ]]; then
   echo Uninstalling docker image honeygain and its updater updaterHG...
   docker stop honeygain >> $LOG 2>&1
   docker rm honeygain >> $LOG 2>&1
   docker rmi honeygain/honeygain >> $LOG 2>&1
   docker stop updaterHG >> $LOG 2>&1
   docker rm updaterHG >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## EarnApp
echo
echo EarnApp: https://earnapp.com/i/zJDVLbf9
if [[ "$APPS" =~ .*"earnapp".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
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
 echo EarnApp installed and running.
 echo IMPORTANT:
 echo Copy the link above and paste it to the address bar of the browser logged in earnapp.
 echo When it is done press enter to continue.
 read continuar
else
 if [[ "$APPS" =~ .*"earnapp".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
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
echo Pawns - IP-Royal: https://pawns.app?r=1262397
if [[ "$APPS" =~ .*"pawns".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
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
 echo Installing docker image pawns with email $emailpawns and password $passpawns and its updater updaterPawns...
 docker stop pawns >> $LOG 2>&1
 docker rm pawns >> $LOG 2>&1
 docker run -d --restart unless-stopped --name pawns iproyal/pawns-cli:latest -email=$emailpawns -password=$passpawns -device-name=$name -device-id=$ident -accept-tos >> $LOG 2>&1
 docker stop updaterPawns >> $LOG 2>&1
 docker rm updaterPawns >> $LOG 2>&1
 docker run -d --name updaterPawns --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower pawns updaterPawns --cleanup --include-stopped --include-restarting --revive-stopped --interval 86430 --scope pawns >> $LOG 2>&1
 echo Pawns installed and running.
else
 echo "Do you want to completely remove it? [yes/NO] :"
 read desinspawns
 desinspawnsmin=$(echo $desinspawns | tr '[:upper:]' '[:lower:]')
 if [[ $desinspawnsmin = "yes" ]]; then
  echo Uninstalling docker image pawns and its updater updaterPawns...
  docker stop pawns >> $LOG 2>&1
  docker rm pawns >> $LOG 2>&1
  docker rmi iproyal/pawns-cli:latest >> $LOG 2>&1
  docker stop updaterPawns >> $LOG 2>&1
  docker rm updaterPawns >> $LOG 2>&1
  echo Done.
 fi
fi

## PacketStream
echo
echo PacketStream: https://packetstream.io/?psr=4tx2
if [[ "$APPS" =~ .*"packetstream".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
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
 echo Installing docker image packetstream with CID $cidps and its updater updaterPS...
 cp -a /etc/rc.local /etc/rc.local.BACK.PR >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64 &' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK > $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64 >> $LOG 2>&1
 docker stop packetstream >> $LOG 2>&1
 docker rm packetstream >> $LOG 2>&1
 docker run -de CID=$cidps --restart unless-stopped --platform linux/arm64 --name packetstream packetstream/psclient:latest >> $LOG 2>&1
 docker stop updaterPS >> $LOG 2>&1
 docker rm updaterPS >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterPS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower packetstream updaterPS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86440 --scope packetstream >> $LOG 2>&1
 echo PacketStream installed and running.
else
 if [[ "$APPS" =~ .*"packetstream".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsps
  desinspsmin=$(echo $desinsps | tr '[:upper:]' '[:lower:]')
  if [[ $desinspsmin = "yes" ]]; then 
   echo Uninstalling docker image packetstream and its updater updaterPS...
   docker stop packetstream >> $LOG 2>&1
   docker rm packetstream >> $LOG 2>&1
   docker rmi packetstream/psclient:latest >> $LOG 2>&1
   docker stop updaterPS >> $LOG 2>&1
   docker rm updaterPS >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## RePocket
echo
echo RePocket: https://link.repocket.co/N6up
if [[ "$APPS" =~ .*"repocket".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
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
 echo Installing docker image repocket con el email $emailrp and API key $apirp and its updater updaterRP...
 docker stop repocket >> $LOG 2>&1
 docker rm repocket >> $LOG 2>&1
 docker run -d -e RP_EMAIL=$emailrp -e RP_API_KEY=$apirp --restart unless-stopped --name repocket repocket/repocket >> $LOG 2>&1
 docker stop updaterRP >> $LOG 2>&1
 docker rm updaterRP >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterRP -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower repocket updaterRP --cleanup --include-stopped --include-restarting --revive-stopped --interval 86450 --scope repocket >> $LOG 2>&1
 echo RePocket installed and running.
else
 if [[ "$APPS" =~ .*"repocket".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsrp
  desinsrpmin=$(echo $desinsrp | tr '[:upper:]' '[:lower:]')
  if [[ $desinrpsmin = "yes" ]]; then
   echo Uninstalling docker image repocket and its updater updaterRP...
   docker stop repocket >> $LOG 2>&1
   docker rm repocket >> $LOG 2>&1
   docker rmi repocket/repocket >> $LOG 2>&1
   docker stop updaterRP >> $LOG 2>&1
   docker rm updaterRP >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## ProxyRack:
echo
echo ProxyRack: https://peer.proxyrack.com/ref/zc9zfiz8nlp8of0mk2mujzbll9iv8sd85vvepfdg
if [[ "$APPS" =~ .*"proxyrack".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
fi
read inspr
insprmin=$(echo $inspr | tr '[:upper:]' '[:lower:]')
if [[ $insprmin = "yes" ]]; then
 echo Please create an account here: https://peer.proxyrack.com/ref/zc9zfiz8nlp8of0mk2mujzbll9iv8sd85vvepfdg
 echo When it is done press enter to continue.
 read continuar
 echo Installing docker image proxyrack and its updater updaterPR...
 cp -a /etc/rc.local /etc/rc.local.BACK.PR >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64 &' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64 >> $LOG 2>&1
 docker stop proxyrack >> $LOG 2>&1
 docker rm proxyrack >> $LOG 2>&1
 cat /dev/urandom | LC_ALL=C tr -dc 'A-F0-9' | dd bs=1 count=64 2>/dev/null > UUID_PR.txt
 export UUID_PR=`cat UUID_PR.txt`
 docker run -de UUID="$UUID_PR" --restart unless-stopped --platform linux/amd64 --name proxyrack --restart unless-stopped proxyrack/pop >> $LOG 2>&1
 docker stop updaterPR >> $LOG 2>&1
 docker rm updaterPR >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterPR -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower proxyrack updaterPR --cleanup --include-stopped --include-restarting --revive-stopped --interval 86460 --scope proxyrack >> $LOG 2>&1
 echo ProxyRack installed and running.
 echo IMPORTANT. The device $name with ID $UUID_PR must be added at: https://peer.proxyrack.com/devices
else
 if [[ "$APPS" =~ .*"proxyrack".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinspr
  desinsprmin=$(echo $desinspr | tr '[:upper:]' '[:lower:]')
  if [[ $desinsprmin = "yes" ]]; then
   echo Uninstalling docker image proxyrack and its updater updaterPR... 
   docker stop proxyrack >> $LOG 2>&1
   docker rm proxyrack >> $LOG 2>&1
   docker rmi proxyrack/pop >> $LOG 2>&1
   docker stop updaterPR >> $LOG 2>&1
   docker rm updaterPR >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## ProxyLite
echo
echo ProxyLite: https://proxylite.ru/?r=VXCFMG4X
if [[ "$APPS" =~ .*"proxylite".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
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
 echo Installing docker image proxylite with ID $idpl and its updater updaterPL...
 cp -a /etc/rc.local /etc/rc.local.ORIG >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64 &' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64 >> $LOG 2>&1
 docker stop proxylite >> $LOG 2>&1
 docker rm proxylite >> $LOG 2>&1
 docker run -de "USER_ID=$idpl" --restart unless-stopped --platform linux/amd64 --name proxylite proxylite/proxyservice >> $LOG 2>&1
 docker stop updaterPL >> $LOG 2>&1
 docker rm updaterPL >> $LOG 2>&1
 docker run -d --name updaterPL --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower proxylite updaterPL --cleanup --include-stopped --include-restarting --revive-stopped --scope proxylite --interval 86420 >> $LOG 2>&1
 echo ProxyLite installed and running.
else
 if [[ "$APPS" =~ .*"proxylite".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinspl
  desinsplmin=$(echo $desinspl | tr '[:upper:]' '[:lower:]')
  if [[ $desinsplmin = "yes" ]]; then
   echo Uninstalling docker image proxylite and its updater updaterPL...
   docker stop proxylite >> $LOG 2>&1
   docker rm proxylite >> $LOG 2>&1
   docker rmi proxylite/proxyservice >> $LOG 2>&1
   docker stop updaterPL >> $LOG 2>&1
   docker rm updaterPL >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## Mysterium
echo
echo Mysterium: https://mystnodes.co/?referral_code=qs4DTlbdhLyEsK0QFFVZYZlsY1MRBrbajZqXhZGc
if [[ "$APPS" =~ .*"mysterium".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
fi
read insmy
insmymin=$(echo $insmy | tr '[:upper:]' '[:lower:]')
if [[ $insmymin = "yes" ]]; then
 echo Please create an account here: https://mystnodes.co/?referral_code=qs4DTlbdhLyEsK0QFFVZYZlsY1MRBrbajZqXhZGc
 echo When it is done press enter to continue.
 read continuar
 echo Installing docker image mysterium and its updater updaterMyst...
 docker stop mysterium >> $LOG 2>&1
 docker rm mysterium >> $LOG 2&1
 docker run -d --cap-add NET_ADMIN -d -p 4449:4449 --name mysterium -v myst-data:/var/lib/mysterium-node --restart unless-stopped mysteriumnetwork/myst:latest service --agreed-terms-and-conditions >> $LOG 2>&1
 docker stop updaterMyst >> $LOG 2>&1
 docker rm updaterMyst >> $LOG 2>&1
 docker run -d --name updaterMyst --restart unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower mysterium updaterMyst --cleanup --include-stopped --include-restarting --revive-stopped --interval 86470 --scope mysterium >> $LOG 2>&1
 echo IMPORTANT: Mysterium needs activation from its dashboard in http://LOCAL-IP:4449. It will prompt for your API key shown on mystnodes.com
 echo In order to avoid forwarding ports or activating UPnP on the router enter Settings, Advanced in the dashboard and place HolePunching to the first place, on top.
 echo When it is done press enter to continue.
 read continuar
 echo Mysterium installed and running.
else
 if [[ "$APPS" =~ .*"mysterium".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsmy
  desinsmymin=$(echo $desinsmy | tr '[:upper:]' '[:lower:]')
  if [[ $desinsmymin = "yes" ]]; then
   echo Uninstalling docker image mysterium and its updater updaterMyst...
   docker stop mysterium >> $LOG 2>&1
   docker rm mysterium >> $LOG 2>&1
   docker rmi mysteriumnetwork/myst:latest >> $LOG 2>&1
   docker stop updaterMyst >> $LOG 2>&1
   docker rm updaterMyst >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## EarnFM
echo
echo EarnFM: https://earn.fm/ref/FRAN6E6B
if [[ "$APPS" =~ .*"earnfm".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
fi
read insef
insefmin=$(echo $insef | tr '[:upper:]' '[:lower:]')
if [[ $insefmin = "yes" ]]; then
 echo Please create an account here: https://earn.fm/ref/FRAN6E6B
 echo When it is done paste your API Key and press enter to continue.
 read efapi
if [[ $efapi == "" ]]; then
  echo API Key cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image earnfm and its updater updaterEF...
 docker stop earnfm >> $LOG 2>&1
 docker rm earnfm >> $LOG 2>&1
 docker run -de EARNFM_TOKEN="$efapi" --restart unless-stopped --name earnfm earnfm/earnfm-client:latest >> $LOG 2>&1
 docker stop updaterEF >> $LOG 2>&1
 docker rm updaterEF >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterEF -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower earnfm updaterEF --cleanup --include-stopped --include-restarting --revive-stopped --interval 86480 --scope earnfm >> $LOG 2>&1
 echo EarnFM installed and running.
else
 if [[ "$APPS" =~ .*"earnfm".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsef
  desinsefmin=$(echo $desinsef | tr '[:upper:]' '[:lower:]')
  if [[ $desinsefmin = "yes" ]]; then
   echo Uninstalling docker image earnfm and its updater updaterEF...
   docker stop earnfm >> $LOG 2>&1
   docker rm earnfm >> $LOG 2>&1
   docker rmi earnfm/earnfm-client:latest >> $LOG 2>&1
   docker stop updaterEF >> $LOG 2>&1
   docker rm updaterEF >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## SpeedShare
echo
echo SpeedShare: https://speedshare.app/?ref=Ferran
if [[ "$APPS" =~ .*"speedshare".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
fi
read insss
insssmin=$(echo $insss | tr '[:upper:]' '[:lower:]')
if [[ $insssmin = "yes" ]]; then
 echo Please create an account here: https://speedshare.app/?ref=Ferran
 echo Go to section Devices, copy the AUTHENTICATION CODE and paste it here.
 echo Once it is done press enter to continue.
 read authcode
 if [[ $authcode == "" ]]; then
  echo The Authentication Code cannot be blank, please launch the script again.
  exit 0
 fi
 echo "Installing native speedshare app (there is no docker image) with the code $authcode to directory /usr/local/bin/..."
 if [ -e /usr/local/bin/speedshare ]; then
  killall speedshare >> $LOG 2>&1
  rm -f /usr/local/bin/speedshare >> $LOG 2>&1
 fi
 wget -qO- https://api.speedshare.app/download/linux/cli/arm64 > /usr/local/bin/speedshare
 chmod +x /usr/local/bin/speedshare
 /usr/local/bin/speedshare connect --pairing_code "$authcode" >> $LOG 2>&1 &
cp -a /etc/rc.local /etc/rc.local.ORIG >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v speedshare /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'speedshare connect --pairing_code $authcode' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 echo SpeedShare installed and running.
else
 if [[ "$APPS" =~ .*"speedshare".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsss
  desinsssmin=$(echo $desinsss | tr '[:upper:]' '[:lower:]')
  if [[ $desinsssmin = "yes" ]]; then
   echo Uninstalling SpeedShare...
   killall speedshare >> $LOG 2>&1
   rm -f /usr/local/bin/speedshare >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## Filecoin Station
echo
echo Filecoin Station: https://www.filstation.app
if [[ "$APPS" =~ .*"filecoinstation".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
else
 echo "Do you want to install it? [yes/NO] :"
fi
read insfs
insfsmin=$(echo $insfs | tr '[:upper:]' '[:lower:]')
if [[ $insfsmin = "yes" ]]; then
 echo You need to have the token FIL in the Polygon network of your Ethereum wallet, it can be done in chainlist.org
 echo When it is done paste your wallet address and press enter to continue.
 read fswallet
 if [[ $apirp == "" ]]; then
  echo Wallet address cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image filecoinstation and its updater updaterFS...
 docker stop filecoinstation >> $LOG 2>&1
 docker rm filecoinstation >> $LOG 2>&1
 docker run -de FIL_WALLET_ADDRESS="$fswallet" --restart unless-stopped --name filecoinstation ghcr.io/filecoin-station/core >> $LOG 2>&1
 docker stop updaterFS >> $LOG 2>&1
 docker rm updaterFS >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterFS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower filecoinstation updaterFS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86490 --scope filecoinstation >> $LOG 2>&1
 echo Filecoin Station installed and running.
else
 if [[ "$APPS" =~ .*"filecoinstation".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsfs
  desinsfsmin=$(echo $desinsfs | tr '[:upper:]' '[:lower:]')
  if [[ $desinsfsmin = "yes" ]]; then
   echo Uninstalling docker image filecoinstation and its updater updaterFS...
   docker stop filecoinstation >> $LOG 2>&1
   docker rm filecoinstation >> $LOG 2>&1
   docker rmi ghcr.io/filecoin-station/core >> $LOG 2>&1
   docker stop updaterFS >> $LOG 2>&1
   docker rm updaterFS >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## Grass
echo
echo Grass: https://app.getgrass.io/register/?referralCode=OleETddLHuKjiki
if [[ "$APPS" =~ .*"grass".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
fi
read insfs
insfsmin=$(echo $insfs | tr '[:upper:]' '[:lower:]')
if [[ $insfsmin = "yes" ]]; then
 echo Please create an account here: https://app.getgrass.io/register/?referralCode=OleETddLHuKjiki
 echo Account email:
 read emailgrass
 if [[ $emailgrass == "" ]]; then
  echo Email cannot be blank, please launch the script again.
  exit 0
 fi
 echo Account password:
 read passgrass
 if [[ $passgrass == "" ]]; then
  echo Password cannot be blank, please launch the script again.
  exit 0
 fi
 echo Installing docker image grass and its updater updaterG...
 docker stop grass >> $LOG 2>&1
 docker rm grass >> $LOG 2>&1
 docker run -d -p 8080:80 -e GRASS_USER="$emailgrass" -e GRASS_PASS="$passgrass" -e ALLOW_DEBUG=False --restart unless-stopped --name grass camislav/grass >> $LOG 2>&1
 docker stop updaterG >> $LOG 2>&1
 docker rm updaterG >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterG -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower grass updaterG --cleanup --include-stopped --include-restarting --revive-stopped --interval 86490 --scope grass >> $LOG 2>&1
 echo Grass installed and running.
else
 if [[ "$APPS" =~ .*"grass".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsg
  desinsgmin=$(echo $desinsg | tr '[:upper:]' '[:lower:]')
  if [[ $desinsgmin = "yes" ]]; then
   echo Uninstalling docker image grass and its updater updaterG...
   docker stop grass >> $LOG 2>&1
   docker rm grass >> $LOG 2>&1
   docker rmi camislav/grass >> $LOG 2>&1
   docker stop updaterG >> $LOG 2>&1
   docker rm updaterG >> $LOG 2>&1
   echo Done.
  fi
 fi
fi

## Meson:
echo
echo Meson: https://meson.network
if [[ "$APPS" =~ .*"meson_cdn".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
fi
read insms
insmsmin=$(echo $insms | tr '[:upper:]' '[:lower:]')
if [[ $insmsmin = "yes" ]]; then
 echo Please create an account here: https://dashboard.meson.network/register
 echo Please paste your token, shown in https://dashboard.meson.network/user/account and press enter :
 read tokenms
 if [[ $tokenms == "" ]]; then
  echo Token cannot be blank, please launch the script again.
  exit 0
 fi
 echo "Meson needs a TCP port forwarded, it is 448 by default, you can specify another if you wish [448]:"
 read portms
 if [[ $portms == "" ]]; then
  portms=448
 fi
 echo "Installing native Meson app (there is no docker image), with token $tokenms and port $portms ..."
 /root/meson_cdn-linux-arm64/service stop meson_cdn >> $LOG 2>&1
 /root/meson_cdn-linux-arm64/service remove meson_cdn >> $LOG 2>&1
 rm -rf /root/meson_cdn-linux-arm64
 cd /root/ >> $LOG 2>&1
 wget 'https://staticassets.meson.network/public/meson_cdn/v3.1.20/meson_cdn-linux-arm64.tar.gz' >> $LOG 2>&1
 tar -zxf meson_cdn-linux-arm64.tar.gz >> $LOG 2>&1
 rm -f /root/meson_cdn-linux-arm64.tar.gz >> $LOG 2>&1
 /root/meson_cdn-linux-arm64/service install meson_cdn >> $LOG 2>&1
 /root/meson_cdn-linux-arm64/meson_cdn config set --token=$tokenms --https_port=$portms --cache.size=30 >> $LOG 2>&1
 /root/meson_cdn-linux-arm64/service start meson_cdn >> $LOG 2>&1
 echo Meson installed and running.
 echo IMPORTANT: Do not forget to open TCP PORT $portms in your router, forwarding it to the LOCAL IP of this device.
else
 echo "Do you want to completely remove it? [yes/NO] :"
 read desinsms
 desinsmsmin=$(echo $desinsms | tr '[:upper:]' '[:lower:]')
 if [[ $desinsmsmin = "yes" ]]; then
  echo Uninstalling Meson...
  /root/meson_cdn-linux-arm64/service stop meson_cdn >> $LOG 2>&1
  /root/meson_cdn-linux-arm64/service remove meson_cdn >> $LOG 2>&1
  rm -rf /root/meson_cdn-linux-arm64
  echo Done.
 fi
fi

## Streamr: NOT INSTALLED BECAUSE IT HAS NOT BEEN WELL TESTED YET
## NOT TRANSLATED FOR THE SAME REASON, IF YOU WANT TO INSTALL IT JUST USE dee.pl OR ANY OTHER TRANSLATOR
#echo
#if [[ "$APPS" =~ .*"streamr".* ]]; then
# echo "Streamr ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
#else
# echo "¿Quiere instalar Streamr? [si/NO] :"
#fi
#read inss
#inssmin=$(echo $inss | tr '[:upper:]' '[:lower:]')
#if [[ $inssmin = "yes" ]]; then
# echo "Para ser Operador de Streamr hay que invertir unos 400 MATIC ($400 ó 350€)"
# echo "Es necesario tener una dirección IP pública y un puerto TCP abierto (por defecto es el 32200)"
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
# echo "Solo tiene que pulsar en el botón Add node address, pegar la dirección del nodo recién creado, darle a guardar y confirmar la transacción."
# echp "Pulse enter cuando haya finalizado, para proceder a la ejecución del nodo Streamr"
# echo "Activando la imagen de docker streamr y el actualizador updaterS..."
# docker run -d -p "$sport":32200 --name streamr --restart unless-stopped -v /root/.streamrDocker:/home/streamr/.streamr streamr/broker-node:v100.0.0-testnet-three.3
# docker stop updaterS >> $LOG 2>&1
# docker rm updaterS >> $LOG 2>&1
# docker run -d --restart unless-stopped --name updaterS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower streamr updaterS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86510 --scope streamr >> $LOG 2>&1
# echo Streamr instalado.
# echo No olvide comprar como mínimo 5000 DATA Tokens y enviarlos a la dirección de su operador para poder obtener recompensas.
#else
# if [[ "$APPS" =~ .*"streamr".* ]]; then
#  echo "¿Quiere eliminar completamente Streamr? [si/NO] :"
#  read desinss
#  desinssmin=$(echo $desinss | tr '[:upper:]' '[:lower:]')
#  if [[ $desinssmin = "yes" ]]; then
#   echo Desinstalando imagen de docker streamr y actualizador updaterS...
#   docker stop streamr >> $LOG 2>&1
#   docker rm streamr >> $LOG 2>&1
#   docker rmi streamr/broker-node:v100.0.0-testnet-three.3 >> $LOG 2>&1
#   docker stop updaterS >> $LOG 2>&1
#   docker rm updaterS >> $LOG 2>&1
#   echo Streamr desinstalado.
#  fi
# fi
#fi

## BitPing:
echo
echo BitPing: https://app.bitping.com?r=hxQvBwhm
if [[ "$APPS" =~ .*"bitping".* ]]; then
 echo "It was already installed. Do you want to reinstall it, for example to alter some parameter? [yes/NO] :"
else
 echo "Do you want to install it? [yes/NO] :"
fi
read insbp
insbpmin=$(echo $insbp | tr '[:upper:]' '[:lower:]')
if [[ $insbpmin = "yes" ]]; then
 echo Please create an account here: https://app.bitping.com?r=hxQvBwhm
 echo When it is done press enter to continue.
 read continuar
 echo Installing docker image bitping and its updater updaterBP...
 cp -a /etc/rc.local /etc/rc.local.BACK.BP >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64 &' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64 >> $LOG 2>&1
 docker stop updaterBP >> $LOG 2>&1
 docker rm updaterBP >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterBP -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower bitping updaterBP --cleanup --include-stopped --include-restarting --revive-stopped --interval 86500 --scope bitping >> $LOG 2>&1
 docker stop bitping >> $LOG 2>&1
 docker rm bitping >> $LOG 2>&1
 echo IMPORTANT:
 echo "This is the last app, we have placed it here because the process is a bit more difficult:"
 echo When asked by the app, insert the account email and password.
 echo Press CTRL+C as soon as you see \'Successfully logged in to Bitping\'
 echo After the app closes please paste the following command and press enter:
 echo
 echo 'docker stop bitping; docker rm bitping; docker run -d --restart unless-stopped --platform linux/amd64 --name bitping -it --mount type=bind,source="/root/bitping/",target=/root/.bitping bitping/bitping-node:latest; echo BitPing installed and running.'
 echo
 echo Once you have copied the command above please press enter to proceed as explained.
 read continuar
 mkdir -p /root/bitping
 docker run --restart unless-stopped --platform linux/amd64 --name bitping -it --mount type=bind,source="/root/bitping/",target=/root/.bitping bitping/bitping-node:latest
else
 if [[ "$APPS" =~ .*"bitping".* ]]; then
  echo "Do you want to completely remove it? [yes/NO] :"
  read desinsbp
  desinsbpmin=$(echo $desinsbp | tr '[:upper:]' '[:lower:]')
  if [[ $desinsbpmin = "yes" ]]; then
   echo Uninstalling docker image bitping and its updater updaterBP...
   docker stop bitping >> $LOG 2>&1
   docker rm bitping >> $LOG 2>&1
   docker rmi bitping/bitping-node:latest >> $LOG 2>&1
   docker stop updaterBP >> $LOG 2>&1
   docker rm updaterBP >> $LOG 2>&1
   echo Done.
  fi
 fi
fi
