#!/bin/bash
#Setup a SCION device which runs Ubuntu 16.04

set -e

#Tested with following devices:
#
#
#
#
#

sudo apt-get -y install git
sudo dpkg --configure -a

#Steps to install scion (github.com/netsec-ethz/scion)
sudo bash -c "echo 'export GOPATH="$HOME/go"' >> ~/.profile"
sudo bash -c "echo 'export PATH="$HOME/.local/bin:$GOPATH/bin:$PATH"' >> ~/.profile"
source ~/.profile
mkdir -p "$GOPATH"

mkdir -p "$GOPATH/src/github.com/netsec-ethz"
cd "$GOPATH/src/github.com/netsec-ethz"

#If no github account is around
git config --global url.https://github.com/.insteadOf git@github.com:

git clone --recursive git@github.com:netsec-ethz/scion
cd scion

#sudo -S chown -R scion: "$GOPATH"

#Fetch commit #1100 (before topology file changes)
sudo git fetch origin caaaaee2a96af340e2ca6b28b59808cbe782c611
sudo git checkout -f FETCH_HEAD

#sudo git cherry-pick 4edac7803665993e87daa7d996840089b07a5fef

#Install the dependencies
APTARGS=-y ./env/deps

#Steps to install scion-web (github.com/netsec-ethz/scion-web)
cd sub/web

pip3 install --user --require-hashes -r requirements.txt
cp web_scion/settings/private.dist.py web_scion/settings/private.py
./manage.py migrate
python3 ./scripts/reload_data.py users

sed -i -e 's/"http://127.0.0.1:8080"/"https://coord.scionproto.net"/g' ad_manager/util/defines.py


