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

function vagrant_box_add {
  if [ -z $boxurl ] || [ -z $boxname ]; then
    echo "set boxurl and boxname." >&2
    return 1
  fi
  mkdir .cache
  wget  $boxurl -P .cache
  unzip .cache/$(basename $boxurl) -d .cache/

  vagrant box add .cache/MSEdge\ -\ Win10.box --name localhost/$boxname
  rm .cache/*
}

function vagrant_init {
  if [ -z $boxname ]; then
    echo "set boxurl and boxname." >&2
    return 1
  fi
  if ! vagrant box list | grep $boxname > /dev/null; then
    vagrant_box_add
  fi
  vagrant up --provider virtualbox
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

  vagrant snapshot save $name
}

function vagrant_reload {

  vagrant_save
  vagrant reload
}

function vagrant_halt {

  vagrant_save
  vagrant halt
}

function vagrant_up {
  vagrant up
}

function vagrant_destroy {
  # vagrant ssh -c "os_type"
  # local os=$(os_type)
  # if [ "${os}" = "rhel" ]; then

  # fi
  vagrant destroy
}

function vagrant_package {
  # defrag
  vagrant ssh -c "
    sudo dd if=/dev/zero of=/EMPTY bs=1M
    sudo rm -f /EMPTY
  "
  vagrant package
}

function usage() {
    cat 1>&2 <<EOF
manage_vagrant
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

  export boxname=MSEdgeWin10
  export boxurl=https://az792536.vo.msecnd.net/vms/VMBuild_20190311/Vagrant/MSEdge/MSEdge.Win10.Vagrant.zip
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
