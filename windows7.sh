
wget https://az792536.vo.msecnd.net/vms/VMBuild_20180102/VirtualBox/IE11/IE11.Win7.VirtualBox.zip -P .cache

wget https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip -P .cache

unzip .cache/IE11.Win7.VirtualBox.zip -d .cache/
unzip .cache/IE11.Win7.Vagrant.zip -d .cache/

local vmname=IE11Win7

VBoxManage import --vsys 0 \
  --vmname $vmname \
  .cache/IE11\ -\ Win7.ova
VBoxManage modifyvm $vmname --memory 2048
VBoxManage modifyvm $vmname --vram 48
VBoxManage modifyvm $vmname --graphicscontroller vmsvga

VBoxManage modifyvm $vmname --clipboard bidirectional
VBoxManage modifyvm $vmname --draganddrop bidirectional

function mount_guestaddition {
  local VboxAdditionIso
  if uname | grep -e Darwin; then
    VboxAdditionIso=/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso
  elif uname | grep -e Linux; then
    VboxAdditionIso=/usr/share/virtualbox/VBoxGuestAdditions.iso

    if [ ! -e $VboxAdditionIso ]; then
      echo "local doesnot exists virtualbox-guestadditions. apt install virtualbox-guest-additions-iso!" >&2
      return 1
    fi
  else
    echo "windows does not support." >&2
    return 1
  fi
  # mount vboxguestadditions
  VBoxManage storagectl $vmname --name SATA --add SATA
  VBoxManage storageattach $vmname \
    --storagectl 'SATA' \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium $VboxAdditionIso
}

