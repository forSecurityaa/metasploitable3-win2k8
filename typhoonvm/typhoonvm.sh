
wget https://download.vulnhub.com/typhoon/Typhoon-v1.02.ova -P .cache/

local vmname=Typhoon-v1.02

VBoxManage import --vsys 0 \
  --vmname $vmname \
  .cache/Typhoon-v1.02.ova
VBoxManage modifyvm $vmname --memory 2048
VBoxManage modifyvm $vmname --vram 48
VBoxManage modifyvm $vmname --graphicscontroller vmsvga

local tmpfile=$(mktemp)
  # remove temporary file return function
  trap "
    rm ${tmpfile}
    trap - RETURN
  " RETURN

echo "16e8fef8230343711f1a351a2b4fb695  .cache/Typhoon-v1.02.ova" >> $tmpfile

# linux
  if uname | grep -e Linux > /dev/null; then
    if which md5sum > /dev/null; then
      echo "install sha1sum" >2
      return 1
    fi
    md5sum --check $tmpfile
    if [ "$?" -ne "0" ]; then
      return 1
    fi
  elif uname | grep -e Darwin -e BSD > /dev/null; then
    if which shasum > /dev/null; then
      echo "install shasum" >2
      return 1
    fi
  fi
