{ lib
, writeScript
, e2fsprogs
, util-linux
, qemu_kvm

, name
, memory
, storage
, threads
, stateImage
, nixStoreImage
, linux
, initrd
, cmdline
}: let
  tinyQemu = qemu_kvm.override {
    nixosTestRunner = true;
    guestAgentSupport = false;
    libiscsiSupport = false;
    capstoneSupport = false;
    hostCpuOnly = true;
  };
in writeScript "run-service-${name}" ''
  if ! [ -e "${stateImage}" ]; then
    touch "${storage}"
    ${e2fsprogs}/bin/chattr +C "${storage}"
    ${util-linux}/bin/fallocate -l "${storage}" "${stateImage}"
  fi
  ${tinyQemu}/bin/qemu-kvm -enable-kvm -drive file="${nixStoreImage}",if=virtio,format=raw,media=disk,readonly=on -drive file="${stateImage}",if=virtio,format=raw,media=disk -nic tap,id=net0,ifname="vm-${name}",model=virtio,script=no,downscript=no -nographic -vga none -serial stdio -monitor none -cpu host -m "${memory}" -smp "${toString threads}" -kernel "${linux}" -initrd "${initrd}" -append "${cmdline}"
''
