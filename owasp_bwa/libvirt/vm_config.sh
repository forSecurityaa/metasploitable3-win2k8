

#
# headless="--type headless"

# virt-install  \
#   --name arch-linux_testing \
#   --memory 1024             \
#   --vcpus=2,maxvcpus=4      \
#   --cpu host                \
#   --cdrom $HOME/Downloads/arch-linux_install.iso \
#   --disk size=2,format=qcow2 \
#   --network user            \
#   --virt-type kvm

# 2GiB, qcow2 フォーマットのボリューム作成; ユーザーネットワーク
# virt-install  \
#   --name arch-linux_testing \
#   --memory 1024             \
#   --vcpus=2,maxvcpus=4      \
#   --cpu host                \
#   --cdrom $HOME/Downloads/arch-linux_install.iso \
#   --disk size=2,format=qcow2 \
#   --network user            \
#   --virt-type kvm

#
# virsh setvcpus kvm_centos7 2

# ssh

# Requested operation is not valid: cannot delete inactive domain with 1 snapshots
