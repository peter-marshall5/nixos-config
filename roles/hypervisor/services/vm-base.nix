{ config, lib, pkgs, modulesPath, ... }: {

  imports = [
    (modulesPath + "/image/repart.nix")
    (modulesPath + "/profiles/image-based-appliance.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
    "vga=normal"
    "console=ttyS0"
    "nomodeset"
  ];

  boot.loader.grub.enable = false;

  boot.initrd.systemd = {
    enable = true;
    storePaths = [
      "${pkgs.btrfs-progs}/bin/btrfs"
      "${pkgs.btrfs-progs}/bin/mkfs.btrfs"
    ];
  };

  image.repart = {
    name = "image";
    split = true;
    partitions = {
      "10-nix-store" = {
        storePaths = [ config.system.build.toplevel ];
        stripNixStorePrefix = true;
        repartConfig = {
          Type = "root";
          Format = "erofs";
          Minimize = "guess";
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = [ "mode=0755" ];
    };

    "/nix/store" = {
      device = "/dev/vda1";
      fsType = "erofs";
      options = [ "ro" ];
    };

    "/home" = {
      device = "/dev/vdb1";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

    "/var" = {
      device = "/dev/vdb1";
      fsType = "btrfs";
      options = [ "subvol=@var" ];
    };
  };

  users.allowNoPasswordLogin = true;
  # services.getty.autologinUser = "root";

  systemd.repart.partitions."10-data" = {
    Type = "linux-generic";
    Format = "btrfs";
    MakeDirectories = "/@home /@var";
    Subvolumes = "/@home /@var";
    FactoryReset = true;
  };

  boot.initrd.systemd.repart = {
    enable = true;
    device = "/dev/vdb";
  };

}
