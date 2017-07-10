# Custom-SCION-Image-creation

A few scripts and a walkthrough to generate customized Images with SCION (and its dependencies) already installed.
Currently it is only creating an Image for an Odroid C1/C1+.

### Installation

1. Clone this repository.

    ```
    git clone --recursive url.https://github.com/ErebosM/Custom-SCION-Image-creation
    cd Custom-SCION-Image-creation
    ```

2. Now run the first script to generate the Ubuntu 16.04 image. It will further prepare and update the image and its packages. After that, the systememulation script will automatically be called.
  
    ```
    ./odroidc1script.sh
    ```

4. Log in as root. The password is "odroid" (Will automatically forces the user to change it after first boot). This last script will install SCION and its dependencies.

    ```
    sudo su - scion
    ./setupdevice.sh
    ```

5. Finished. If everything went right, we can now shutdown the emulated machine and flash the image to a micro SD-card.

    ```
    sudo shutdown -h now
    lsblk
    cd ubuntu
    sudo dd if=image.img of=/dev/XXXX bs=1M
    ```
