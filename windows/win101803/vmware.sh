
function box_add {
  mkdir .cache

  wget https://az792536.vo.msecnd.net/vms/VMBuild_20190311/VMware/MSEdge/MSEdge.Win10.VMware.zip -P .cache
  unzip .cache/MSEdge.Win10.VMware.zip -d .cache/
  local name=MSEdgeWin10_64

  open -a "vmware Fusion" .cache/MSEdge-Win10-VMware/MSEdge-Win10-VMware.ovf

}

function cache_clear {
  rm .cache/*
}
box_add $@

# open rdp://[username[:password]@]hostname[:port][/domain][?parameters]

# open rdp://IEUser:Passw0rd!@localhost
