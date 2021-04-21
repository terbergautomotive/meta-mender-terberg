

## Preparing flashing EasyInstall on the board

* Plug in the USB cable.
* Restart the board in recovery mode.
    * Turn off board.
    * Press and hold Recovery mode button
    * Power on board
    * Release Recovery mode after 6 seconds
* Download and extract the [EasyInstall script](https://docs.toradex.com/104473-colibri-imx7_toradexeasyinstaller_beta.zip) for imx7 
* Run `recovery-linux.sh`

The end result is EasyInstall running in the board RAM.
Connect the board to the internet and flash the EasyInstall on the mmc.

This is the starting point for the next step.

## Building the mender image

```
mkdir oe-core-easy && cd oe-core-easy
curl https://storage.googleapis.com/git-repo-downloads/repo > repo
chmod 755 repo
./repo init -u git@github.com:terbergautomotive/terberg-bsp-platform.git -b LinuxImageV2.8-terberg
./repo sync

# A temporary manual step. 
# It won't be needed as this gets merged into https://github.com/terbergautomotive/meta-mender-terberg
# Before the merge this readme will be removed from this repo and become the readme for https://github.com/terbergautomotive/terberg-bsp-platform
cd layers/
rm -rf meta-mender-terberg/
git clone -b mender-easyinstall-integration git@github.com:mendersoftware/ps-meta-mender-terberg.git meta-mender-terberg
cd ..

export TEMPLATECONF=${PWD}/layers/meta-mender-terberg/conf
source layers/openembedded-core/oe-init-build-env
bitbake-layers add-layer ../layers/meta-mender-terberg/
echo 'MENDER_SERVER_URL = "https://hosted.mender.io"' >> conf/local.conf

# Update with your hosted mender tenant token
echo 'MENDER_TENANT_TOKEN = "<YOUR-HOSTED-MENDER-TENANT-TOKEN>"' >> conf/local.conf

# Add quicker intervals for demo purposes to reduce waiting times
cat >> conf/local.conf << "EOF"
MENDER_UPDATE_POLL_INTERVAL_SECONDS_pn-mender ?= "30"                                                                                                          
MENDER_INVENTORY_POLL_INTERVAL_SECONDS_pn-mender ?= "30"                                                                                                              
MENDER_RETRY_POLL_INTERVAL_SECONDS_pn-mender ?= "30"                                                                                                                  
EOF

bitbake console-tdx-image

cd tmp-glibc/deploy/images/colibri-imx7-emmc
mkdir toradex_easy_install_dir
cp mender-tezi-metadata/* toradex_easy_install_dir/
cp image-Console-Image.json toradex_easy_install_dir/image.json
cp Console-Image-colibri-imx7-emmc.sdimg.bz2 toradex_easy_install_dir/
cp u-boot.imx toradex_easy_install_dir/
```
# Flashing the image via EasyInstall

Copy the directory `torader_easy_install_dir` on to a USB stick.
Plug the USB stick into the board.
A new entry will pop up in the EasyInstall menu, select and install it.

