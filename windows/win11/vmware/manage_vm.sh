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
  unzip ./.cache/Win*.VMware.zip -d .cache/
}
function vagrant_box_add {
  VBoxManage import --vsys 0 \
    --vmname $vmname \
    .cache/Win*-disk1.vmdk
  # .cache/WinDev2202Eval-disk1.vmdk
  # inflating: .cache/WinDev2202Eval.mf
  # inflating: .cache/WinDev2202Eval.ovf
}

function vagrant_init {
  if [ -z $vmname ]; then
    echo "set boxurl and boxname." >&2
    return 1
  fi
  if [ ! -f ./.cache/$vmname.ova ]; then
    vagrant_download
  fi
  if ! VBoxManage list vms | grep $vmname > /dev/null; then
    vagrant_box_add
  fi
  vagrant_up
  vagrant_save init
  vagrant_provision
}

function vagrant_save {

  local description=$1
  if [ -z $description ]; then
    description=snapshot
  fi
  local format="%Y%m%dT%H%M%SZ"
  local name=$(date +"${format}")
  VBoxManage snapshot $vmname take $name --description $description
}

function vagrant_reload {

  vagrant_halt
  vagrant_up
}

function vagrant_halt {

  vagrant_save
  VBoxManage controlvm $vmname acpipowerbutton
}

function vagrant_up {
  local file_path=$(dirname $0)
  source $file_path/vm_config.sh
  VBoxManage startvm $vmname $headless
}

function vagrant_destroy {
  VBoxManage unregistervm $vmname --delete
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
  if ! command -v VBoxManage > /dev/null; then
    echo "install virtualbox!" >&2
  fi
  export vmname="Win11en_us"
  export boxurl=https://aka.ms/windev_VM_vmware

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
