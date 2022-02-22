#!/bin/bash
#
# utils, often use.

function os_type {
    for arg in "$@"; do
    case "$arg" in
      -h|--help)
        function usage() {
          cat 1>&2 << END
os_type
output search engine setting
USAGE:
    gnu_alias [FLAGS] [OPTIONS]
FLAGS:
    -h, --help              Prints help information
OPTIONS:
    --debug                 Set bash debug Option
END
          unset -f usage
        }
        usage
        return
        ;;
      --debug)
        # set debug
        set -x
        trap "
          set +x
          trap - RETURN
        " RETURN
        ;;
      *)
        ;;
    esac
  done

  local os_type

  if ls /etc | grep fedora-release > /dev/null; then
    os_type=fedora
  elif ls /etc | grep redhat-release > /dev/null; then
    os_type=rhel
    # debian systems except ubuntu.
  elif ls /etc | grep debian_version > /dev/null; then
    os_type=debian
  elif ls /etc | grep lsb-release > /dev/null; then
    os_type=ubuntu
  elif ls /etc | grep SuSE-release > /dev/null; then
    os_type=SuSE
    # if you use BSD,
  elif uname | grep -e Darwin -e BSD > /dev/null; then
    os_type=$(uname | grep -e Darwin -e BSD)
  fi

  if [ -z $os_type ]; then
    echo "unknown os" >&2
    return 1
  fi

  echo $os_type
}

function vagrant_provision {
  # vagrant ssh -c "
  #   cd /vagrant_data
  #   ./invoke.sh
  # "
  : pass
}

function is_checksum {

  local tmpfile=$(mktemp)
  # remove temporary file return function
  trap "
    rm ${tmpfile}
    trap - RETURN
  " RETURN

  echo "a119a0bc238040c284119269209858628cf82a72 OWASP_Broken_Web_Apps_VM_1.2.ova" >> $tmpfile
  # linux
  if uname | grep -e Linux > /dev/null; then
    if which sha1sum > /dev/null; then
      echo "install sha1sum" >2
      return 1
    fi
    sha1sum --check $tmpfile
    if [ "$?" -ne "0" ]; then
      return 1
    fi
  elif uname | grep -e Darwin -e BSD > /dev/null; then
    if which shasum > /dev/null; then
      echo "install shasum" >2
      return 1
    fi
  fi
}

function vagrant_download {
  if [ -z $boxurl ] || [ -z $vmname ]; then
    echo "set boxurl and boxname." >&2
    return 1
  fi
  if [ ! -d ./.cache ]; then
    mkdir ./.cache
  fi

  wget --content-disposition $boxurl -P .cache/
  tar -xvf .cache/${vmname}.ova -C ./.cache/
}
function vagrant_box_add {

  qemu-img convert -f vmdk -O qcow2 \
    ./.cache/${vmname}-disk1.vmdk \
    ./.cache/${vmname}-disk1.qcow2
  # sudo mv ./.cache/${vmname}-disk1.qcow2 /var/lib/libvirt/images/${vmname}-disk1.qcow2
  # owasp_bwa はubuntu10.04相当
  virt-install  \
    --name $vmname \
    --os-variant ubuntu10.04 \
    --memory 2048 \
    --vcpus=1,maxvcpus=2 \
    --description "offenseive security" \
    --disk path=./.cache/${vmname}-disk1.qcow2,bus=sata \
    --import

    # --disk path=/var/lib/libvirt/images/${vmname}-disk1.qcow2,bus=sata \
  virsh shutdown --mode acpi
}

function vagrant_init {
  if [ -z $vmname ]; then
    echo "set boxurl and boxname." >&2
    return 1
  fi
  if [ ! -f ./.cache/$vmname.ova ]; then
    vagrant_download
  fi
  if ! virsh list --all | grep $vmname > /dev/null; then
    vagrant_box_add
  fi
  vagrant_up
  vagrant_save init
  vagrant_provision
}

function vagrant_save {

  local name=$1
  # --prefixなども考える
  if [ -z $name ]; then
    # local format="${prefix} %Y-%m-%dT%H:%M:%S"
    local format="%Y%m%dT%H%M%S"
    name=$(date +"${format}")
  fi

  # description
  virsh snapshot-create-as --domain $vmname --name $name --description "snap1"
}

function vagrant_reload {

  vagrant_halt
  vagrant_up
}

function vagrant_halt {

  vagrant_save
  virsh shutdown $vmname --mode acpi
}

function vagrant_up {

  status=$(systemctl status libvirtd | \
    grep Active | \
    sed 's/^.*Active: //' | \
    cut -d ' ' -f 1)

  if [ 'active' != ${status} ]; then
    echo "check libvirtd service status!" >&2
    return 1
  fi
  local file_path=$(dirname $0)
  source $file_path/vm_config.sh
  virsh start $vmname
}

function vagrant_destroy {

  # delete all snapshot
  virsh snapshot-list --domain $vmname | \
    sed 1,2d | \
    cut -d ' ' -f 2 | \
    xargs -I {} virsh snapshot-delete --domain $vmname --snapshotname {}

  virsh undefine $vmname --remove-all-storage
}

function usage() {
    cat 1>&2 <<EOF
manage_vm
output search engine setting

USAGE:
    manage_vagrant [FLAGS] [OPTIONS]

FLAGS:
    init
    save
    up
    halt
    destroy
    -h, --help              Prints help information

OPTIONS:
    --debug                 Set bash debug Option
EOF
}

function main {
  if ! command -v virsh > /dev/null; then
    echo "install virsh!" >&2
  fi
  local version=1.2
  export vmname="OWASP_Broken_Web_Apps_VM_${version}"
  export boxurl=https://sourceforge.net/projects/owaspbwa/files/${version}/${vmname}.ova/download

  local i
  local new_array=( $@ )
  for ((i=0;i<$#;i++)); do
    if [ "${new_array[$i]}" = "--help" ] || [ "${new_array[$i]}" = "-h" ]; then
      usage
      return
    fi
    # if find --debug flag from args, start debug mode.
    if [ "${new_array[$i]}" = "--debug" ]; then
      set -x
      trap "
        set +x
        trap - RETURN
      " RETURN
      unset new_array[$i]
    fi
  done

  # reindex assign.
  new_array=${new_array[@]}
  vagrant_${new_array[0]}
}

main $@
