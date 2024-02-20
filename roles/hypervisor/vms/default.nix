# Manually-installed VMs.
{ config, lib, pkgs, nixosInstaller, nixosConfigurations, ... }:

let

  cfg = config.ab.vms;

  tinyQemu = pkgs.qemu_kvm.override {
    nixosTestRunner = true;
    guestAgentSupport = false;
    libiscsiSupport = false;
    capstoneSupport = false;
    hostCpuOnly = true;
  };

  firmware = (tinyQemu + "/share/qemu/edk2-x86_64-code.fd");

  vmOpts = { name, ... }: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      memory = lib.mkOption {
        type = lib.types.str;
        default = "512M";
      };
      threads = lib.mkOption {
        type = lib.types.int;
        default = 1;
      };
      mac = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

in

{

  options.ab.vms = {
    stateDir = lib.mkOption {
      default = "/var/lib/guests";
      type = lib.types.str;
    };
    guests = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule vmOpts);
    };
  };

  config = {

    ab.net.bridge.enable = true;

    ab.vms.guests = lib.mapAttrs (n: system: {
      inherit (system.config.ab) memory threads mac;
    }) (lib.filterAttrs (n: system:
      system.config.ab.hardware == "virt" &&
      system.config.ab.host == config.networking.hostName
    ) nixosConfigurations);

    system.activationScripts.microvm-host = ''
      mkdir -p ${cfg.stateDir}
    '';

    environment.systemPackages = [
      tinyQemu
      (pkgs.writeScriptBin "install-guest" ''
        set -e
        [ "$1" != "" ]
        [ "$2" != "" ]

        store="${cfg.stateDir}/$1"
        mkdir -p "$store"
        hda="$store/hda.img"
        vars="$store/VARS-x86_64.fd"

        installer="${nixosInstaller}"

        [ "$3" != "" ] && installer="$3"

        # Initialize the associated files
        if ! test -f $hda; then
          echo Creating associated guest files
          touch $hda
          ${pkgs.e2fsprogs}/bin/chattr +C $hda # Improves performance on btrfs
          ${pkgs.util-linux}/bin/fallocate -l "$2" "$hda"
          cat ${tinyQemu}/share/qemu/edk2-i386-vars.fd > $vars # EFI variables store
        fi

        echo Running the guest with the installation ISO
        ${tinyQemu}/bin/qemu-kvm -drive file="$installer",if=virtio,format=raw,media=disk,readonly=on -drive file=$hda,if=virtio,format=raw,media=disk -nic tap,id=net0,ifname="vm-$name",model=virtio,script=no,downscript=no -nographic -vga none -serial stdio -cpu host -m 2G -drive if=pflash,format=raw,unit=0,file=${firmware},readonly=on -drive if=pflash,format=raw,unit=1,file=$vars -monitor unix:$sock,server,nowait
      '')
    ];

    systemd.services = lib.mkMerge ([{"guest@" = {
      restartIfChanged = false;
      scriptArgs = "%i";
      script = (''
        store="${cfg.stateDir}/$1"
        if ! [ -e "$store" ]; then
          echo "Error: The specified host has not been initialized yet."
          echo "Use 'vm-install name disk-size' to install its OS."
          exit 1
        fi

        hda="$store/hda.img"
        vars="$store/VARS-x86_64.fd"
        sock="/run/guest-$1.api.sock"
        rm -f $sock

        ${tinyQemu}/bin/qemu-kvm -drive file=$hda,if=virtio,format=raw,media=disk -nic tap,id=net0,ifname="vm-$1",model=virtio,script=no,downscript=no,mac="$MAC_ADDRESS" -nographic -vga none -serial none -cpu host -smp $THREADS -m $MEMORY -drive if=pflash,format=raw,unit=0,file=${firmware},readonly=on -drive if=pflash,format=raw,unit=1,file=$vars -monitor unix:$sock,server,nowait
      '');
    };} (builtins.listToAttrs (map ({ name, threads, memory, mac }: lib.nameValuePair "guest@${name}" {
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      overrideStrategy = "asDropin";
      environment = {
        THREADS = toString threads;
        MEMORY = memory;
        MAC_ADDRESS = mac;
      };
    }) (lib.attrValues cfg.guests)))]);

  };
}
