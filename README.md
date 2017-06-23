# Custom-SCION-Image-creation

A few scripts and a walkthrough to generate customized Images with SCION (and its dependencies) already installed.
Currently it is only creating an Image for an Odroid C1/C1+.

### Installation

1. Clone this repository.

```
git clone --recursive url.https://github.com/ErebosM/Custom-SCION-Image-creation
cd Custom-SCION-Image-creation
```

2. Now run the first script to generate the Ubuntu 16.04 image. It will further prepare and update the image and its packages.

```
chmod +x odroidc1script.sh
./odroidc1script.sh
```
3. As we have the image without SCION on it, the last step is, to install SCION. To do so, as SCION needs to run Go, we need to emulate the whole system and can't use user mode emulation for it. This next script will load the needed files to do so and starts the emulation.

```
chmod +x systememulation.sh
./systememulation
```

4. Log in as root. The password is "odroid" (Will automatically forces the user to change it after first boot). The last script is about installing SCION and its dependencies.

```
sudo su - scion
./setupdevice.sh
```
