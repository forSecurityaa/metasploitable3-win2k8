

function download {
  if ! which wget > /dev/null; then
    echo "Please install wget!"
    return 1
  fi

  mkdir .cache
  # クラス変数に相当する環境変数
  local version=1.2
  local filename="OWASP_Broken_Web_Apps_VM_${version}"
  wget --content-disposition "https://sourceforge.net/projects/owaspbwa/files/${version}/${filename}.ova/download" -P .cache/

  wget --content-disposition https://drive.google.com/file/d/1fPGBGcmCgvoAejVUGtb-0PqGYnEDcdeB/view?usp=sharing
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

function start_vm {

  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi
  # if you set headless.
  local headless=headless
  --headless
  VBoxManage startvm $vmname --type $headless
}

function snapshot_save {

  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi
  local name=
  VBoxManage snapshot $vmname take $name
}

function snapshot_list {

  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi
  VBoxManage snapshot $vmname list

}

function snapshot_delete {

  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi
  local name=
  VBoxManage snapshot $vmname delete $name
}

function snapshot_restore {

  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi

  local name=
  VBoxManage snapshot $vmname restore $name

}

function halt {
  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi
  VBoxManage controlvm $vmname poweroff
}

function destroy {
  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi
  VBoxManage unregistervm $vmname --delete
}

function up {

  if which VBoxManage > /dev/null; then
    echo "install VBoxManage" >2
    return 1
  fi
  local vmname=OWASP_Broken_Web_Apps_VM_1.2

  VBoxManage import --vsys 0 \
    --vmname $vmname \
    .cache/OWASP_Broken_Web_Apps_VM_1.2.ova

  if [ "$?" -ne "0" ]; then
    return 1
  fi

  VBoxManage modifyvm $vmname --memory 2048
  VBoxManage modifyvm $vmname --graphicscontroller vmsvga
  VBoxManage modifyvm $vmname --nic1 hostonly
  VBoxManage modifyvm $vmname --macaddress1 auto

  VBoxManage snapshot $vmname take "init"



}

VBoxManage storagectl $vmname --name IDE --add IDE
  # mount vboxguestadditions
  # VBoxManage storageattach $vmname \
  #     --storagectl 'IDE' \
  #     --port 1 \
  #     --device 0 \
  #     --type dvddrive \
  #     --medium "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
  # VBoxManage guestcontrol $vmname updateadditions

  # local username=root
  # local password=owaspbwa

  # VBoxManage guestcontrol $vmname start --exe /bin/ls --username $username --password $password --wait-stdout
  # VBoxManage guestcontrol $vmname run --exe /bin/ls --username $username --password $password --wait-stdout
  # # create public key for vagrant
  # ssh-keygen -yf $HOME/.vagrant.d/insecure_private_key > authorized_keys
  # useradd -m vagrant
  # su - vagrant

  mkdir .cache
  wget https://download.vulnhub.com/stapler/Stapler.zip -P .cache/

  if ! which unzip > /dev/null; then
    echo "Please install unzip!"
    return 1
  fi

  unzip .cache/Stapler.zip -d .cache/

  local vmname=Stapler

  VBoxManage import --vsys 0 \
    --vmname $vmname \
    --settingsfile ~/VirtualBox\ Vms/Stapler/Stapler.vbox \
    .cache/Stapler/Stapler.ovf
  VBoxManage modifyvm $vmname --memory 2048
  VBoxManage modifyvm $vmname --graphicscontroller vmsvga
  VBoxManage modifyvm $vmname --macaddress1 auto


function usage() {
    cat 1>&2 <<EOF
owasp_bwa
output search engine setting

USAGE:
    set_color [FLAGS] [OPTIONS]

FLAGS:
    -c, --color             Set you want to output color.
    -f, --fields            Show usable search engines.
    -h, --help              Prints help information

OPTIONS:
    -d, --delim             set for parse. default value is comma ",".
    --debug                 Set bash debug Option
EOF
}

function main {

  # set default version
  export version=1.2
  export filename="OWASP_Broken_Web_Apps_VM_${version}"

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

  set_color $new_array
}





main $@
