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

#Fetch commit #1100 (before topology file changes)
sudo git fetch origin caaaaee2a96af340e2ca6b28b59808cbe782c611
sudo git checkout -f FETCH_HEAD

#sudo git cherry-pick 4edac7803665993e87daa7d996840089b07a5fef
sed -i -e 's/4fc9c2ff7924b3a1fa326e1799e5dd58cac585d7fb25fe53ccaa1333b0453d665/b3b02911eb1f6ada203b0763ba924234629b51586f72a21faacc638269f4ced5/g' env/pip3/requirements.txt

#Install the dependencies
export PATH=$PATH:$GOPATH/bin
APTARGS=-y ./env/deps

sudo dpkg --configure -a

#Steps to install scion-web (github.com/netsec-ethz/scion-web)
cd sub/web

pip3 install --user --require-hashes -r requirements.txt
cp web_scion/settings/private.dist.py web_scion/settings/private.py
./manage.py migrate
python3 ./scripts/reload_data.py users

sed -i -e 's|http://127.0.0.1:8080|https://coord.scionproto.net|g' ad_manager/util/defines.py

