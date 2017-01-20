###################  Made by 45khz   ####################
########## ROADWARRIOR DEAMONSAW ROUTER SETUP ###########
## wget URL -O road_demon.sh && bash road_demon.sh ##

#vars
FILEPATHDS="$HOME"
ROUTER_ADDRESS="0.0.0.0"
HOME_ADDRESS="127.0.0.1"
WAN_ADDRESS="$(wget -qO- ipv4.icanhazip.com)"
LAN_ADDRESS="$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)"
PORT_NUMBER="8080"

#start q
read -e -p "Enter where you want Demonsaw to be installed if untouched Default path= " -i "$FILEPATHDS" FILEPATHDS
echo "You entered: $FILEPATHDS"
mkdir $FILEPATHDS

#get tha ipz
echo "Enter ip for the router"
 echo "   1) WAN $WAN_ADDRESS (External)"
 echo "   2) LAN $LAN_ADDRESS (Internal)"
 echo "   3) LOCAL $HOME_ADDRESS (Localhost)"
  read -p "Select an option [1-3]:" ROUTER_ADDRESS
 case $ROUTER_ADDRESS in
1)
ROUTER_ADDRESS="$WAN_ADDRESS"
;;
2)
ROUTER_ADDRESS="$LAN_ADDRESS"
;;
3)
ROUTER_ADDRESS="$HOME_ADDRESS"
;;
esac

read -e -p "Enter what port Demonsaw will talk on (most be 1024 or above otherwise root is needed) untouched Default port=:" -i "$PORT_NUMBER" PORT_NUMBER
echo "You entered: $PORT_NUMBER"

#Get teh Demons
if [ ! -d $FILEPATHDS/demonsaw ]; then
 mkdir $FILEPATHDS/demonsaw
 wget https://demonsaw.com/download/3.1.0/demonsaw_debian_64.tar.gz -P /tmp/
 tar -xvzf /tmp/demonsaw_debian_64.tar.gz -C $FILEPATHDS/demonsaw/
 rm /tmp/demonsaw_debian_64.tar.gz*
else echo "you already have demonsaw downloaded and extracted it nice"
fi

#Make .toml
if [ ! -f $FILEPATHDS/demonsaw/demonsaw.toml ]; then
 echo "demonsaw.toml not found, lets fix that!"
 touch $FILEPATHDS/demonsaw/demonsaw.toml
 else echo "looks like you already have the config file (demonsaw.toml) let update"
fi
#make the .toml file
(
echo -e "[demonsaw]\nversion = 0\n[[router]]\naddress = '$ROUTER_ADDRESS'\nport = $PORT_NUMBER\nthreads = 128\n[router.network]\nredirect = 'https://demonsaw.com'\nmotd = 'Roadwarriors Demonsaw/Enigma router'\n" )>$FILEPATHDS/demonsaw/demonsaw.toml

echo "Config Done"
echo "Your router is going to be avalible with ip=$ROUTER_ADDRESS port=$PORT_NUMBER"
echo "What do you want to do now?"
 echo "   1) Start router (one time)"
 echo "   2) Start router on boot (Presistance)"
 echo "   3) Start router (in window only testing)"
 echo "   4) Exit)"
  read -p "Select an option [1-4]:" ROUTER_START
 case $ROUTER_START in
1)
cd "$FILEPATHDS/demonsaw/"
nohup ./demonsaw_cli >/dev/null 2>&1 &
echo "Your done, have a nice day"
;;
2)
touch $FILEPATHDS/demonsaw/autostart
(echo -e "cd $FILEPATHDS/demonsaw\nnohup ./demonsaw_cli >/dev/null 2>&1 &")>$FILEPATHDS/demonsaw/autostart
(crontab -l 2>/dev/null; echo "@reboot bash $FILEPATHDS/demonsaw/autostart") | crontab -
cd "$FILEPATHDS/demonsaw/"
nohup ./demonsaw_cli >/dev/null 2>&1 &
echo "Your done, have a nice day"
;;
3)
cd "$FILEPATHDS/demonsaw/"
./demonsaw_cli
;;
4)
exit
;;
esac
