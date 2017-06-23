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
./odroidc1script.sh
```
3. As we have the image without SCION on it, the last step is, to install SCION. To do so, as SCION needs to run Go, we need to emulate the whole system and can't use user mode emulation for it. This next script will load the needed files to do so and starts the emulation.

```
./systememulation.sh
```

4. Log in as root. The password is "odroid" (Will automatically forces the user to change it after first boot). The last script will install SCION and its dependencies.

<b>TODO:</b> Before running the script, you have to change the file `env/deps/pip3/requirements.txt` to this commit of the main scion repository 4edac7803665993e87daa7d996840089b07a5fef (you can also try to cherry-pick)



```
sudo su - scion
./setupdevice.sh
```

5. Finished. If everything went right, we can now shutdown the emulated machine and flash the image to a micro SD-card.

```
sudo shutdown -h now
lsblk
sudo dd if=image.img of=/dev/XXXX bs=1M
```
