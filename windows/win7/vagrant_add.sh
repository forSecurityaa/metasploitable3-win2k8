
function box_add {
  mkdir .cache
  wget https://az792536.vo.msecnd.net/vms/VMBuild_20150916/Vagrant/IE11/IE11.Win7.Vagrant.zip -P .cache
  unzip .cache/IE11.Win7.Vagrant.zip -d .cache/

  local name=IE11windows7

  vagrant box add .cache/IE11\ -\ Win7.box --name localhost/$name

  rm .cache/*
}

box_add $@
