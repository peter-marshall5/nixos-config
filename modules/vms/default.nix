{ config, lib, pkgs, nixosInstaller, ... }:

let

  cfg = config.ab.vms;

  tinyQemu = pkgs.qemu_kvm.override {
    nixosTestRunner = true;
    guestAgentSupport = false;
    libiscsiSupport = false;
    capstoneSupport = false;
    hostCpuOnly = true;
  };

  vmOpts = { name, ... }: {
    options = {
      hostName = lib.mkOption {
        default = name;
        type = lib.types.str;
      };
      memory = lib.mkOption {
        type = lib.types.str;
      };
      diskSize = lib.mkOption {
        type = lib.types.str;
      };
      cpus = lib.mkOption {
        type = lib.types.int;
      };
      os = lib.mkOption {
        type = lib.types.str;
      };
      macAddress = lib.mkOption {
        default = "";
        type = lib.types.str;
      };
    };

  };

in

{

  options.ab.vms = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
    guests = lib.mkOption {
      default = {};
      type = with lib.types; attrsOf (submodule vmOpts);
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      { assertion = config.ab.net.bridge.enable; }
    ];

    environment.systemPackages = [
      tinyQemu
    ];

    systemd.services = lib.mapAttrs' (name: guest: lib.nameValuePair "guest-${name}" {
      wantedBy = [ "multi-user.target" ];
      script = ''
        disks=/var/lib/guests/disks
        mkdir -p "$disks"
        hda="$disks/${name}.img"
        vars="$disks/${name}.VARS-x86_64.fd"
        size="${guest.diskSize}"

        firmware="${tinyQemu}/share/qemu/edk2-x86_64-code.fd"

        sock="/run/guest-${name}.api.sock"
        rm -f $sock

        # Initialize the associated files
        if ! test -f $hda; then
          touch $hda
          ${pkgs.e2fsprogs}/bin/chattr +C $hda # Improves performance on btrfs
          ${pkgs.util-linux}/bin/fallocate -l "$size" "$hda"
          cat ${tinyQemu}/share/qemu/edk2-i386-vars.fd > $vars # EFI variables store
        fi

        # Run the installation process
        if ! test -f $hda.installed; then
          ${tinyQemu}/bin/qemu-kvm -drive file=${nixosInstaller},if=virtio,format=raw,media=disk,readonly=on -drive file=$hda,if=virtio,format=raw,media=disk -nic tap,id=net0,ifname="vm-$name",model=virtio,script=no,downscript=no -nographic -vga none -serial file:$hda.console.log -cpu host -m 2G -drive if=pflash,format=raw,unit=0,file=$firmware,readonly=on -drive if=pflash,format=raw,unit=1,file=$vars -monitor unix:$sock,server,nowait
          touch $hda.installed
        fi

        # Run the guest without the installation media present
        ${tinyQemu}/bin/qemu-kvm -drive file=$hda,if=virtio,format=raw,media=disk -nic tap,id=net0,ifname=vm-${name},model=virtio,script=no,downscript=no -nographic -vga none -serial none -cpu host -smp ${toString guest.cpus} -m ${guest.memory} -drive if=pflash,format=raw,unit=0,file=$firmware,readonly=on -drive if=pflash,format=raw,unit=1,file=$vars -monitor unix:$sock,server,nowait
      '';
      preStop = ''
        echo 'system_powerdown' | ${pkgs.socat}/bin/socat - UNIX-CONNECT:/run/guest-${name}.api.sock
        sleep 10
      '';
    }) cfg.guests;

    ab.net.bridge.vmTaps = lib.mapAttrs (name: guest: { inherit (guest) macAddress; }) cfg.guests;
  };
}
