
function box_add {
  mkdir .cache
  wget https://az792536.vo.msecnd.net/vms/VMBuild_20190311/Vagrant/MSEdge/MSEdge.Win10.Vagrant.zip -P .cache
  unzip .cache/MSEdge.Win10.Vagrant.zip -d .cache/

  wget https://az792536.vo.msecnd.net/vms/VMBuild_20190311/VMware/MSEdge/MSEdge.Win10.VMware.zip -P .cache
  local name=MSEdgeWin10_64

  vagrant box add .cache/MSEdge\ -\ Win10.box --name localhost/$name

  rm .cache/*
}

box_add $@

open rdp://[username[:password]@]hostname[:port][/domain][?parameters]

open rdp://IEUser:Passw0rd!@localhost
