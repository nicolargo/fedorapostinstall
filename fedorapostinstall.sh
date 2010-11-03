#!/bin/bash
# Mon script de post installation Fedora
#
# Nicolargo - 11/2010
# GPL
#
# Syntaxe: # su -c ./fedorainstall.sh
VERSION="1.0"

#=============================================================================
# Liste des applications à installer

# GStreamer (la totale)
LISTE=`yum -q list available '*gstreamer*' | awk '{print $1 }' | grep gstreamer | xargs -eol`
# Dev
LISTE=$LISTE" gcc subversion vim-enhanced"
# Desktop Gnome
LISTE=$LISTE" fortune-mod gnome-applet-netspeed compiz-manager gnome-do gnome-do-plugins pavucontrol"
# Desktop Theme: http://www.llaumgui.com/post/theme-equinox-et-icone-faenza
LISTE=$LISTE" gtk-equinox-engine faenza-icon-theme"
# Multimedia
LISTE=$LISTE" x264 ffmpeg2theora oggvideotools istanbul shotwell mplayer-gui gimp ogmrip banshee gnome-do-plugins-banshee ipod-sharp guvcview wavpack mppenc faac flac faad2 lame cheese sound-juicer picard shutter vlc clementine darktable"
# Network
LISTE=$LISTE" iperf ifstat wireshark arp-scan nmap"
# System
LISTE=$LISTE" hardinfo htop wine conky terminator lm_sensors"
# Web
LISTE=$LISTE" chromium pino pidgin purple-plugin_pack-pidgin"

#=============================================================================

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # su -c $0" 1>&2
  exit 1
fi

# Ajout des depots
#-----------------

# Chromium: http://fedoraproject.org/wiki/Chromium
cd /etc/yum.repos.d
wget http://repos.fedorapeople.org/repos/spot/chromium/fedora-chromium.repo
cd -

# RPM Fusion: http://rpmfusion.org/Configuration/
yum -y localinstall --nogpgcheck http://fr2.rpmfind.net/linux/rpmfusion/free/fedora/rpmfusion-free-release-stable.noarch.rpm http://fr2.rpmfind.net/linux/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm

# Mise a jour de la liste des depots
#-----------------------------------

echo "Mise a jour de la liste des depots"
yum update

# Installations additionnelles
#-----------------------------

# echo "Installation des logiciels de dev"
# yum groupinstall "Development Tools" "Development Libraries" "X Software Development" "GNOME Software Development"

echo "Installation des logiciels suivants: $LISTE"
yum -y install $LISTE

# libdvdcss: http://download.videolan.org/pub/libdvdcss/
cd /tmp
LIBDVDCSS_VERSION="1.2.10"
wget http://download.videolan.org/pub/libdvdcss/$LIBDVDCSS_VERSION/libdvdcss-$LIBDVDCSS_VERSION.tar.gz
tar zxvf libdvdcss-$LIBDVDCSS_VERSION.tar.gz
cd libdvdcss-$LIBDVDCSS_VERSION
./configure
make
make install
cd -

# Fortune
cd /usr/share/games/fortune/
wget http://www.fortunes-fr.org/data/litterature_francaise
strfile litterature_francaise litterature_francaise.dat
wget http://www.fortunes-fr.org/data/personnalites
strfile personnalites personnalites.dat
wget http://www.fortunes-fr.org/data/proverbes
strfile proverbes proverbes.dat
wget http://www.fortunes-fr.org/data/philosophie
strfile philosophie philosophie.dat
wget http://www.fortunes-fr.org/data/sciences
strfile sciences sciences.dat
cd -

# Custom du systeme
gconftool-2 --type Boolean --set /desktop/gnome/interface/menus_have_icons True

# Dropbox scripts (http://blog.nicolargo.com/2010/09/scripts-nautilus-pour-partagerdepartager-ses-fichiers-avec-dropbox.html)
wget http://svn.nicolargo.com/ubuntupostinstall/trunk/Dropbox%20Share
wget http://svn.nicolargo.com/ubuntupostinstall/trunk/Dropbox%20UnShare
mv Dropbox\ Share Dropbox\ UnShare ~/.gnome2/nautilus-scripts/
chmod a+x ~/.gnome2/nautilus-scripts/Dropbox*

# Conky theme (http://tiny.cc/7cyle)
#cd ~
#wget http://dl.dropbox.com/u/1112933/conky-faenza-nicolargo.tar.gz
#tar zxvf conky-faenza-nicolargo.tar.gz 
#~/.conky-startup.sh &
#cd -

# Sensors detect
sensors-detect

# Restart Nautilus
nautilus -q

echo "========================================================================"
echo
echo "1) Ajouter le profil audio MP3 HQ: gnome-audio-profiles-properties"
echo ">> audio/x-raw-int,rate=44100,channels=2 ! lamemp3enc name=enc target=1 bitrate=320 cbr=1 ! id3v2mux"
echo
echo "2) Theme Gnome (Système/Préference/Apparence): Equinox Evolution"
echo
echo "3) Ajouter ~/.conky-startup.sh dans les Applications au demarrage"
echo 
echo "========================================================================"

# Fin du script
#---------------

