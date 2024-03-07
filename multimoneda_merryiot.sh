#!/bin/bash
#
# Script de Instalación de MultiMonedas en hotspot Browan MerryIoT
# EarnApp, PacketStream, RePocket, Proxyrack, ProxyLite, EarnFM, SpeedShare, Filecoin Station y BitPing.
# Grass, Meson, MASQ* están en fase Testnet: aun sin pagos reales.
# Streamr y Presearch* requieren comprar una cantidad significativa de tokens para recibir beneficios.
# *En futuras versiones, junto con las que aun no están en linux: bytelixir.com/r/Z0FR2SD6FECW , cashraven.io , spider.com , community.theta.tv/theta-edge-node , nodle.com
# Versión: 1.5.2
# Licencia: GPLv3
#

# Aquí puede indicar el archivo de registro:
LOG=/var/log/multimoneda.log

# Descomente para registrar del resultado de absolutamente todos los comandos (útil para depuración):
#exec 1> >(tee $LOG) 2>&1

# Descomente para Streamr (experto):
#echo "Instalar (o reinstalar) y desinstalar aplicaciones EarnApp, PacketStream, RePocket, Proxyrack, ProxyLite, EarnFM, SpeedShare, Filecoin Station, Grass, Meson, Streamr y BitPing"
echo "Instalar (o reinstalar) y desinstalar aplicaciones EarnApp, PacketStream, RePocket, Proxyrack, ProxyLite, EarnFM, SpeedShare, Filecoin Station, Grass, Meson y BitPing"
echo
echo "Escriba un nombre para diferenciar este MerryIoT de otros dispositivos (sin espacios) y presione enter:"
read nombre
if [[ $nombre == "" ]]; then
 echo No puede dejar el nombre en blanco. Vuelva a ejecutar el script.
 exit 0
fi
ident=$(cat /etc/hostname)

## Actualizar e instalar utilidades de seguridad
echo
echo "Actualizando el sistema..."
if [ ! -e /etc/apt/sources.list.d/docker.list ]; then
 echo "Instalando Docker (oficial)..."
 curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && echo "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >> $LOG 2>&1
 apt update >> $LOG 2>&1
 apt install -y --no-install-recommends --purge docker-ce >> $LOG 2>&1
 systemctl enable docker >> $LOG 2>&1
 systemctl restart docker >> $LOG 2>&1
fi
if [ ! -e /etc/docker/daemon.json ]; then
 echo Limitando logs de docker a 10 MB y tres arhivos
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
echo Actualizando los paquetes con apt, esto puede tardar...
apt update >> $LOG 2>&1
apt --purge full-upgrade -y >> $LOG 2>&1
apt install -y unattended-upgrades fail2ban >> $LOG 2>&1
apt --purge autoremove -y >> $LOG 2>&1
apt clean >> $LOG 2>&1
echo Utilidades instaladas y sistema asegurado y actualizado.
if [ ! -e /dev/net/tun ]; then
 /usr/local/sbin/multiple_miner.sh kernelUpdate >> $LOG 2>&1
 echo "Es necesario reiniciar el sistema. Pasado un minuto vuelva a conectar y ejecutar el script de la misma forma. Presione enter para continuar..."
 read reiniciar
 reboot >> $LOG 2>&1
fi

## Listado de aplicaciones instaladas actualmente
echo
echo Aplicaciones instaladas actualmente:
echo
# Descomente para Streamr (experto):
#APPS=`docker ps -a --format '{{.Names}}' | grep -F -e tm -e honeygain -e iproypaw -e packetstream -e repocket -e proxyrack -e proxylite -e myst -e earnfm -e filecoinstation -e grass -e bitping -e streamr | tee /dev/tty`
APPS=`docker ps -a --format '{{.Names}}' | grep -F -e tm -e honeygain -e iproypaw -e packetstream -e repocket -e proxyrack -e proxylite -e myst -e earnfm -e filecoinstation -e grass -e bitping | tee /dev/tty`
APPS+=" "`ps axco command | grep -F -e earnapp -e speedshare -e meson_cdn | sort | uniq | tee /dev/tty`
if [[ "$APPS" = " " ]]; then
 echo No hay aplicaciones instaladas.
fi

## EarnApp
echo
echo EarnApp: https://earnapp.com/i/zJDVLbf9
if [[ "$APPS" =~ .*"earnapp".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insea
inseamin=$(echo $insea | tr '[:upper:]' '[:lower:]')
if [[ $inseamin = "si" ]]; then
 echo Es necesario registro previo en https://earnapp.com/i/zJDVLbf9
 echo Cuando lo haya hecho pulse enter para continuar.
 read continuar
 echo "Instalando el servicio nativo de earnapp (no hay imagen de docker)..."
 if [ -e /usr/bin/earnapp ]; then
  earnapp uninstall
 fi
 wget -qO- https://brightdata.com/static/earnapp/install.sh > /tmp/earnapp.sh
 bash /tmp/earnapp.sh
 echo EarnApp instalado y funcionando.
 echo IMPORTANTE:
 echo Tiene que copiar el enlace que aparece arriba y pegarlo en el navegador donde se haya registrado con earnapp.
 echo Cuando lo haya hecho pulse enter para continuar.
 read continuar
else
 if [[ "$APPS" =~ .*"earnapp".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsea
  desinseamin=$(echo $desinsea | tr '[:upper:]' '[:lower:]')
  if [[ $desinseamin = "si" ]]; then
   echo Desinstalando EarnApp...
   earnapp uninstall
   echo EarnApp desinstalado.
  fi
 fi
fi

## PacketStream
echo
echo PacketStream: https://packetstream.io/?psr=4tx2
if [[ "$APPS" =~ .*"packetstream".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insps
inspsmin=$(echo $insps | tr '[:upper:]' '[:lower:]')
if [[ $inspsmin = "si" ]]; then
 echo Es necesario registro previo en https://packetstream.io/?psr=4tx2
 echo "Ponga su CID (aparece entre las instrucciones, estando identificado, en la sección de Linux de https://packetstream.io/dashboard/download buscando CID=) :"
 read cidps
 if [[ $cidps == "" ]]; then
  echo No puede dejar el CID en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo Instalando imagen de docker packetstream con el CID $cidps y actualizador updaterPS...
 cp -a /etc/rc.local /etc/rc.local.BACK.PR >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm  tonistiigi/binfmt --install amd64' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64 >> $LOG 2>&1
 docker stop packetstream >> $LOG 2>&1
 docker rm packetstream >> $LOG 2>&1
 docker run -de CID=$cidps --restart unless-stopped --platform linux/arm64 --name packetstream packetstream/psclient:latest >> $LOG 2>&1
 docker stop updaterPS >> $LOG 2>&1
 docker rm updaterPS >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterPS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower packetstream updaterPS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86440 --scope packetstream >> $LOG 2>&1
 echo PacketStream instalado y funcionando.
else
 if [[ "$APPS" =~ .*"packetstream".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsps
  desinspsmin=$(echo $desinsps | tr '[:upper:]' '[:lower:]')
  if [[ $desinspsmin = "si" ]]; then 
   echo Desinstalando imagen de docker packetstream y actualizador updaterPS...
   docker stop packetstream >> $LOG 2>&1
   docker rm packetstream >> $LOG 2>&1
   docker rmi packetstream/psclient:latest >> $LOG 2>&1
   docker stop updaterPS >> $LOG 2>&1
   docker rm updaterPS >> $LOG 2>&1
   echo PacketStream desinstalado.
  fi
 fi
fi

## RePocket
echo
echo RePocket: https://link.repocket.co/N6up
if [[ "$APPS" =~ .*"repocket".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insrp
insrpmin=$(echo $insrp | tr '[:upper:]' '[:lower:]')
if [[ $insrpmin = "si" ]]; then
 echo Es necesario registro previo en https://link.repocket.co/N6up
 echo Email registrado:
 read emailrp
 if [[ $emailrp == "" ]]; then
  echo No puede dejar el email en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo "Pegue la clave API que muestra la web cuando ingresa con sus credenciales (Api Key):"
 read apirp
 if [[ $apirp == "" ]]; then
  echo No puede dejar la clave API en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo Instalando imagen de docker repocket con el email $emailrp y la clave api $apirp y actualizador updaterRP...
 docker stop repocket >> $LOG 2>&1
 docker rm repocket >> $LOG 2>&1
 docker run -d -e RP_EMAIL=$emailrp -e RP_API_KEY=$apirp --restart unless-stopped --name repocket repocket/repocket >> $LOG 2>&1
 docker stop updaterRP >> $LOG 2>&1
 docker rm updaterRP >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterRP -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower repocket updaterRP --cleanup --include-stopped --include-restarting --revive-stopped --interval 86450 --scope repocket >> $LOG 2>&1
 echo RePocket instalado y funcionando.
else
 if [[ "$APPS" =~ .*"repocket".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsrp
  desinsrpmin=$(echo $desinsrp | tr '[:upper:]' '[:lower:]')
  if [[ $desinrpsmin = "si" ]]; then
   echo Desinstalando imagen de docker repocket y actualizador updaterRP...
   docker stop repocket >> $LOG 2>&1
   docker rm repocket >> $LOG 2>&1
   docker rmi repocket/repocket >> $LOG 2>&1
   docker stop updaterRP >> $LOG 2>&1
   docker rm updaterRP >> $LOG 2>&1
   echo RePocket desinstalado.
  fi
 fi
fi

## ProxyRack
echo
echo ProxyRack: https://peer.proxyrack.com/ref/zc9zfiz8nlp8of0mk2mujzbll9iv8sd85vvepfdg
if [[ "$APPS" =~ .*"proxyrack".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read inspr
insprmin=$(echo $inspr | tr '[:upper:]' '[:lower:]')
if [[ $insprmin = "si" ]]; then
 echo Es necesario registro previo en https://peer.proxyrack.com/ref/zc9zfiz8nlp8of0mk2mujzbll9iv8sd85vvepfdg
 echo Cuando lo haya hecho pulse enter para continuar.
 read continuar
 echo Instalando imagen de docker proxyrack y actualizador updaterPR...
 cp -a /etc/rc.local /etc/rc.local.BACK.PR >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm  tonistiigi/binfmt --install amd64' >> /etc/rc.local.OK
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
 echo ProxyRack instalado y funcionando.
 echo IMPORTANTE. Dar de alta el dispositivo $nombre con el ID $UUID_PR en https://peer.proxyrack.com/devices
else
 if [[ "$APPS" =~ .*"proxyrack".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinspr
  desinsprmin=$(echo $desinspr | tr '[:upper:]' '[:lower:]')
  if [[ $desinsprmin = "si" ]]; then
   echo Desinstalando imagen de docker proxyrack y actualizador updaterPR... 
   docker stop proxyrack >> $LOG 2>&1
   docker rm proxyrack >> $LOG 2>&1
   docker rmi proxyrack/pop >> $LOG 2>&1
   docker stop updaterPR >> $LOG 2>&1
   docker rm updaterPR >> $LOG 2>&1
   echo ProxyRack desinstalado.
  fi
 fi
fi

## ProxyLite
echo
echo ProxyLite: https://proxylite.ru/?r=VXCFMG4X
if [[ "$APPS" =~ .*"proxylite".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read inspl
insplmin=$(echo $inspl | tr '[:upper:]' '[:lower:]')
if [[ $insplmin = "si" ]]; then
 echo Es necesario registro previo en https://proxylite.ru/?r=VXCFMG4X
 echo ID de tu usuario:
 read idpl
 if [[ $idpl == "" ]]; then
  echo No puede dejar el ID en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo Instalando imagen de docker proxylite con el ID $idpl y actualizador updaterPL...
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
 docker stop updaterPL  >> $LOG 2>&1
 docker rm updaterPL  >> $LOG 2>&1
 docker run -d --name updaterPL --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower proxylite updaterPL --cleanup --include-stopped --include-restarting --revive-stopped  --scope proxylite --interval 86420  >> $LOG 2>&1
 echo ProxyLite instalado y funcionando.
else
 if [[ "$APPS" =~ .*"proxylite".* ]]; then
  echo "¿Quiere eliminar completamente ProxyLite? [si/NO] :"
  read desinspl
  desinsplmin=$(echo $desinspl | tr '[:upper:]' '[:lower:]')
  if [[ $desinsplmin = "si" ]]; then
   echo Desinstalando imagen de docker proxylite y actualizador updaterPL...
   docker stop proxylite >> $LOG 2>&1
   docker rm proxylite >> $LOG 2>&1
   docker rmi proxylite/proxyservice >> $LOG 2>&1
   docker stop updaterPL >> $LOG 2>&1
   docker rm updaterPL >> $LOG 2>&1
   echo ProxyLite desinstalado.
  fi
 fi
fi

## EarnFM
echo
echo EarnFM: https://earn.fm/ref/FRAN6E6B
if [[ "$APPS" =~ .*"earnfm".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insef
insefmin=$(echo $insef | tr '[:upper:]' '[:lower:]')
if [[ $insefmin = "si" ]]; then
 echo Es necesario registro previo en https://earn.fm/ref/FRAN6E6B
 echo Cuando lo haya hecho pegue su API Key y pulse enter para continuar.
 read efapi
if [[ $efapi == "" ]]; then
  echo No puede dejar la clave API en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo Instalando la imagen de docker earnfm y el actualizador updaterEF...
 docker stop earnfm >> $LOG 2>&1
 docker rm earnfm >> $LOG 2>&1
 docker run -de EARNFM_TOKEN="$efapi" --restart unless-stopped --name earnfm earnfm/earnfm-client:latest >> $LOG 2>&1
 docker stop updaterEF >> $LOG 2>&1
 docker rm updaterEF >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterEF -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower earnfm updaterEF --cleanup --include-stopped --include-restarting --revive-stopped --interval 86480 --scope earnfm >> $LOG 2>&1
 echo EarnFM instalado y funcionando.
else
 if [[ "$APPS" =~ .*"earnfm".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsef
  desinsefmin=$(echo $desinsef | tr '[:upper:]' '[:lower:]')
  if [[ $desinsefmin = "si" ]]; then
   echo Desinstalando imagen de docker earnfm y actualizador updaterEF...
   docker stop earnfm >> $LOG 2>&1
   docker rm earnfm >> $LOG 2>&1
   docker rmi earnfm/earnfm-client:latest >> $LOG 2>&1
   docker stop updaterEF >> $LOG 2>&1
   docker rm updaterEF >> $LOG 2>&1
   echo EarnFM desinstalado.
  fi
 fi
fi

## SpeedShare
echo
echo SpeedShare: https://speedshare.app/?ref=Ferran
if [[ "$APPS" =~ .*"speedshare".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insss
insssmin=$(echo $insss | tr '[:upper:]' '[:lower:]')
if [[ $insssmin = "si" ]]; then
 echo Es necesario registro previo en https://speedshare.app/?ref=Ferran
 echo Una vez hecho vaya a la sección Devices, copie el AUTHENTICATION CODE y péguelo aquí.
 echo Cuando lo haya hecho pulse enter para continuar.
 read authcode
 if [[ $authcode == "" ]]; then
  echo No puede dejar el código de autenticación en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo "Instalando el servicio nativo de speedshare (no hay imagen de docker) con el código $authcode..."
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
 echo SpeedShare instalado y funcionando.
else
 if [[ "$APPS" =~ .*"speedshare".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsss
  desinsssmin=$(echo $desinsss | tr '[:upper:]' '[:lower:]')
  if [[ $desinsssmin = "si" ]]; then
   echo Desinstalando SpeedShare...
   killall speedshare >> $LOG 2>&1
   rm -f /usr/local/bin/speedshare >> $LOG 2>&1
   echo SpeedShare desinstalado.
  fi
 fi
fi

## Filecoin Station
echo
echo Filecoin Station: https://www.filstation.app
if [[ "$APPS" =~ .*"filecoinstation".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insfs
insfsmin=$(echo $insfs | tr '[:upper:]' '[:lower:]')
if [[ $insfsmin = "si" ]]; then
 echo Es necesario tener el token FIL en la red Polygon de su billetera Ethereum, puede enlazarla usando la web chainlist.org
 echo Cuando lo haya hecho pegue la dirección de su billetera y pulse enter para continuar.
 read fswallet
 if [[ $fswallet == "" ]]; then
  echo No puede dejar la billetera en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo Instalando la imagen de docker filecoinstation y el actualizador updaterFS...
 docker stop filecoinstation >> $LOG 2>&1
 docker rm filecoinstation >> $LOG 2>&1
 docker run -de FIL_WALLET_ADDRESS="$fswallet" --restart unless-stopped --name filecoinstation ghcr.io/filecoin-station/core >> $LOG 2>&1
 docker stop updaterFS >> $LOG 2>&1
 docker rm updaterFS >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterFS -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower filecoinstation updaterFS --cleanup --include-stopped --include-restarting --revive-stopped --interval 86490 --scope filecoinstation >> $LOG 2>&1
 echo Filecoin Station instalado y funcionando.
else
 if [[ "$APPS" =~ .*"filecoinstation".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsfs
  desinsfsmin=$(echo $desinsfs | tr '[:upper:]' '[:lower:]')
  if [[ $desinsfsmin = "si" ]]; then
   echo Desinstalando imagen de docker filecoinstation y actualizador updaterFS...
   docker stop filecoinstation >> $LOG 2>&1
   docker rm filecoinstation >> $LOG 2>&1
   docker rmi ghcr.io/filecoin-station/core >> $LOG 2>&1
   docker stop updaterFS >> $LOG 2>&1
   docker rm updaterFS >> $LOG 2>&1
   echo Filecoin Station desinstalado.
  fi
 fi
fi

## Grass
echo
echo Grass: https://app.getgrass.io/register/?referralCode=OleETddLHuKjiki
if [[ "$APPS" =~ .*"grass".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insfs
insfsmin=$(echo $insfs | tr '[:upper:]' '[:lower:]')
if [[ $insfsmin = "si" ]]; then
 echo Es necesario registro previo en https://app.getgrass.io/register/?referralCode=OleETddLHuKjiki
 echo Email registrado:
 read emailgrass
 if [[ $emailgrass == "" ]]; then
  echo No puede dejar el email en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo Clave con la que se ha registrado:
 read passgrass
 if [[ $passgrass == "" ]]; then
  echo No puede dejar la clave en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo Instalando la imagen de docker grass y el actualizador updaterG...
 docker stop grass >> $LOG 2>&1
 docker rm grass >> $LOG 2>&1
 docker run -d -p 8080:80 -e GRASS_USER="$emailgrass" -e GRASS_PASS="$passgrass" -e ALLOW_DEBUG=False --restart unless-stopped --name grass camislav/grass >> $LOG 2>&1
 docker stop updaterG >> $LOG 2>&1
 docker rm updaterG >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterG -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower grass updaterG --cleanup --include-stopped --include-restarting --revive-stopped --interval 86490 --scope grass >> $LOG 2>&1
 echo Grass instalado y funcionando.
else
 if [[ "$APPS" =~ .*"grass".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsg
  desinsgmin=$(echo $desinsg | tr '[:upper:]' '[:lower:]')
  if [[ $desinsgmin = "si" ]]; then
   echo Desinstalando imagen de docker grass y actualizador updaterG...
   docker stop grass >> $LOG 2>&1
   docker rm grass >> $LOG 2>&1
   docker rmi camislav/grass >> $LOG 2>&1
   docker stop updaterG >> $LOG 2>&1
   docker rm updaterG >> $LOG 2>&1
   echo Grass desinstalado.
  fi
 fi
fi

## Meson
echo
echo Meson: https://meson.network
if [[ "$APPS" =~ .*"meson_cdn".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insms
insmsmin=$(echo $insms | tr '[:upper:]' '[:lower:]')
if [[ $insmsmin = "si" ]]; then
 echo Es necesario registro previo en https://dashboard.meson.network/register
 echo Ponga su token, aparece en https://dashboard.meson.network/user/account :
 read tokenms
 if [[ $tokenms == "" ]]; then
  echo No puede dejar el token en blanco. Vuelva a ejecutar el script.
  exit 0
 fi
 echo "Meson necesita un puerto TCP abierto en el router, por defecto es el 448, si quiere puede cambiarlo (si no pulse enter):"
 read portms
 if [[ $portms == "" ]]; then
  portms=448
 fi
 echo Instalando el servicio nativo de Meson, no hay imagen de docker, con el token $tokenms y el puerto $portms...
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
 echo Meson instalado y funcionando.
 echo IMPORTANTE: No olvide abrir el puerto $portms TCP en el router hacia la IP local de este dispositivo.
else
 echo "¿Quiere eliminarlo completamente? [si/NO] :"
 read desinsms
 desinsmsmin=$(echo $desinsms | tr '[:upper:]' '[:lower:]')
 if [[ $desinsmsmin = "si" ]]; then
  echo Desinstalando Meson...
  /root/meson_cdn-linux-arm64/service stop meson_cdn >> $LOG 2>&1
  /root/meson_cdn-linux-arm64/service remove meson_cdn >> $LOG 2>&1
  rm -rf /root/meson_cdn-linux-arm64
  echo Meson desinstalado.
 fi
fi

## Streamr: NO LO INSTALAMOS POR ESTAR EN BETA
#echo
#if [[ "$APPS" =~ .*"streamr".* ]]; then
# echo "Streamr ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
#else
# echo "¿Quiere instalar Streamr? [si/NO] :"
#fi
#read inss
#inssmin=$(echo $inss | tr '[:upper:]' '[:lower:]')
#if [[ $inssmin = "si" ]]; then
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
# echo Streamr instalado y funcionando.
# echo No olvide comprar como mínimo 5000 DATA Tokens y enviarlos a la dirección de su operador para poder obtener recompensas.
#else
# if [[ "$APPS" =~ .*"streamr".* ]]; then
#  echo "¿Quiere eliminar completamente Streamr? [si/NO] :"
#  read desinss
#  desinssmin=$(echo $desinss | tr '[:upper:]' '[:lower:]')
#  if [[ $desinssmin = "si" ]]; then
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

## BitPing
echo
echo BitPing: https://app.bitping.com?r=hxQvBwhm
if [[ "$APPS" =~ .*"bitping".* ]]; then
 echo "Ya estaba instalado ¿Quiere reinstalarlo, por ejemplo para alterar sus parámetros? [si/NO] :"
else
 echo "¿Quiere instalarlo? [si/NO] :"
fi
read insbp
insbpmin=$(echo $insbp | tr '[:upper:]' '[:lower:]')
if [[ $insbpmin = "si" ]]; then
 echo Es necesario registro previo en https://app.bitping.com?r=hxQvBwhm
 echo Cuando lo haya hecho pulse enter para continuar.
 read continuar
 echo Instalando imagen de docker bitping y actualizador updaterBP...
 cp -a /etc/rc.local /etc/rc.local.BACK.BP >> $LOG 2>&1
 grep -F -v exit /etc/rc.local > /etc/rc.local.AUX
 grep -F -v tonistiigi /etc/rc.local.AUX > /etc/rc.local.OK
 rm -f /etc/rc.local.AUX >> $LOG 2>&1
 echo 'docker run --privileged --rm tonistiigi/binfmt --install amd64' >> /etc/rc.local.OK
 echo 'exit 0' >> /etc/rc.local.OK
 chmod +x /etc/rc.local.OK >> $LOG 2>&1
 cp -a /etc/rc.local.OK /etc/rc.local >> $LOG 2>&1
 docker run --privileged --rm tonistiigi/binfmt --install amd64  >> $LOG 2>&1
 docker stop updaterBP >> $LOG 2>&1
 docker rm updaterBP >> $LOG 2>&1
 docker run -d --restart unless-stopped --name updaterBP -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower bitping updaterBP --cleanup --include-stopped --include-restarting --revive-stopped --interval 86500 --scope bitping >> $LOG 2>&1
 docker stop bitping >> $LOG 2>&1
 docker rm bitping >> $LOG 2>&1
 echo IMPORTANTE:
 echo "Esta es la última aplicación, la hemos puesto aquí porque el proceso es algo más complicado:"
 echo Cuando se lo pida bitping introduzca el email y el password registrados.
 echo Una vez que aparezca \"Successfully logged in to Bitping\" hay que cerrar manualmente bitping pulsando CTRL+C
 echo Cuando se cierre hay que pegar manualmente el siguiente comando y pulsar enter, entonces habremos terminado:
 echo
 echo 'docker stop bitping; docker rm bitping; docker run -d --restart unless-stopped --platform linux/amd64 --name bitping -it --mount type=bind,source="/root/bitping/",target=/root/.bitping bitping/bitping-node:latest; echo BitPing instalado y funcionando.'
 echo
 echo Cuando haya copiado el comando de arriba pulse enter para finalizar segun lo explicado.
 read continuar
 mkdir -p /root/bitping
 docker run --restart unless-stopped --platform linux/amd64 --name bitping -it --mount type=bind,source="/root/bitping/",target=/root/.bitping bitping/bitping-node:latest
else
 if [[ "$APPS" =~ .*"bitping".* ]]; then
  echo "¿Quiere eliminarlo completamente? [si/NO] :"
  read desinsbp
  desinsbpmin=$(echo $desinsbp | tr '[:upper:]' '[:lower:]')
  if [[ $desinsbpmin = "si" ]]; then
   echo Desinstalando imagen de docker bitping y actualizador updaterBP...
   docker stop bitping >> $LOG 2>&1
   docker rm bitping >> $LOG 2>&1
   docker rmi bitping/bitping-node:latest >> $LOG 2>&1
   docker stop updaterBP >> $LOG 2>&1
   docker rm updaterBP >> $LOG 2>&1
   echo BitPing desinstalado.
  fi
 fi
fi
