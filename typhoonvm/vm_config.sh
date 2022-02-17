

#
# headless="--type headless"

VBoxManage modifyvm $vmname --memory 2048
VBoxManage modifyvm $vmname --vram 48
VBoxManage modifyvm $vmname --graphicscontroller vmsvga
