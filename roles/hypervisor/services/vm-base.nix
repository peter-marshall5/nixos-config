{ config, lib, pkgs, modulesPath, ... }: {

  imports = [
    (modulesPath + "/image/repart.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  image.repart = {
    name = "image";
    partitions = {
      "10-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Minimize = "guess";
          MakeDirectories = "/home /var";
        };
      };
    };
  };

  ab.fs.enable = false;

  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [ "ro" ];
  };

  fileSystems."/home" = {
    device = "/dev/vdb1";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/var" = {
    device = "/dev/vdb1";
    fsType = "btrfs";
    options = [ "subvol=@var" ];
  };

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
