#!/usr/bin/env bash
set -x

VERSION='9.6.0'
URL="https://mirror.yandex.ru/debian-cd/${VERSION}/amd64/iso-cd/"
ISO="debian-${VERSION}-amd64-xfce-CD-1.iso"

#VERSION='18.04.1.0'
#URL="https://mirror.yandex.ru/ubuntu-releases/${VERSION}"
#ISO="ubuntu-${VERSION}-live-server-amd64.iso"

for f in 'wget' 'wget'; do
    if [ `which ${f}` = '' ]; then
        echo "ERROR: You need to install ${f}!"
        exit 1
    fi
done

for f in 'MD5SUMS' ${ISO}; do
    if [[ ! -e ${f} ]]; then
        wget "${URL}/${f}" -O ${f}
    fi
done

grep ${ISO} 'MD5SUMS' | md5sum -c
if [[ ! $? -eq 0 ]]; then
    exit 2
fi

exit


# vm
OSTYPE='Ubuntu_64'
VM_NAME_GATEWAY='FoxyGateway'

VBoxManage list ostypes | grep ${OSTYPE} > /dev/null
if [[ ! $? -eq 0 ]]; then
    exit 3
fi

VBoxManage list vms | grep ${VM_NAME_GATEWAY}
if [[ ! $? -eq 0 ]]; then
    VBoxManage createvm --name ${VM_NAME_GATEWAY} \
        --ostype ${OSTYPE} \
        --basefolder ${PWD} \
        --register
    VBoxManage modifyvm ${VM_NAME_GATEWAY} \
        --memory 1024 \
        --biossystemtimeoffset -36000000 \
        --nic1 nat \
        --nic2 intnet
    VBoxManage modifyvm ${VM_NAME_GATEWAY} --intnet2 "foxynet"  #?

    hdd="${PWD}/${VM_NAME_GATEWAY}/hdd.vdi"
    VBoxManage createhd --filename ${hdd} --size 10240 --variant Standard
    
    storage='SATA'
    VBoxManage storagectl ${VM_NAME_GATEWAY} --name ${storage} --add sata --bootable on  #todo ports
    VBoxManage storageattach ${VM_NAME_GATEWAY} --storagectl ${storage} \
        --port 0 --device 0 --type hdd --medium ${hdd}
    VBoxManage storageattach ${VM_NAME_GATEWAY} --storagectl ${storage} \
        --port 1 --device 0 --type dvddrive --medium ${ISO}
    VBoxManage startvm ${VM_NAME_GATEWAY}
fi
