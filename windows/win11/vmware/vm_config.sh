

#
# headless="--type headless"

VBoxManage modifyvm $vmname --memory 2048
VBoxManage modifyvm $vmname --graphicscontroller vmsvga
# VBoxManage modifyvm $vmname --nic1 hostonly
VBoxManage modifyvm $vmname --macaddress1 auto
