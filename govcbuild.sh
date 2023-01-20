#!/bin/bash

butane --pretty --strict twingatedocker.bu --output twingatedocker.ign && echo "success" || echo "failed" 

CONFIG_ENCODING='base64'
CONFIG_ENCODED=$(cat twingatedocker.ign | base64 -w0 -)
source govcsource 
govc session.login 
govc about

VM_NAME='twingate-name-here'
IMAGE='fedora-coreos-37.20221127.3.0-vmware.x86_64.ova-hw19'
govc vm.power -off "${VM_NAME}"
govc vm.destroy "${VM_NAME}"

govc vm.clone -vm "${IMAGE}" -on=false "${VM_NAME}"
govc vm.network.change -vm "${VM_NAME}" -net "${GOVC_NETWORK2}" ethernet-0 
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data.encoding=${CONFIG_ENCODING}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data=${CONFIG_ENCODED}"
govc vm.info -e "${VM_NAME}"
govc vm.info "${VM_NAME}"
govc device.info -vm "${VM_NAME}"
read -p "Press any key to resume ..."
govc vm.power -on "${VM_NAME}"
