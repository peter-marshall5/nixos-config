{ lib, pkgs
, nixpkgs
, modulesPath
, ...}:

let

  efiArch = pkgs.stdenv.hostPlatform.efiArch;
  kernelPath = "/EFI/Linux/kernel.efi";

  systemConfig = { config, lib, pkgs, ... }: {
    image.repart.name = "image";
    image.repart.partitions = {
      "10-esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

          "/loader/entries/nixos.conf".source = pkgs.writeText "nixos.conf" ''
            title NixOS
            linux /EFI/nixos/kernel.efi
            initrd /EFI/nixos/initrd.efi
            options init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}
          '';

          "/EFI/nixos/kernel.efi".source =
            "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";

          "/EFI/nixos/initrd.efi".source =
            "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "esp-src";
          SizeMinBytes = "96M";
        };
      };
      "20-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "btrfs";
          Label = "nixos-src";
          Minimize = "guess";
        };
      };
    };

    boot.loader.systemd-boot.enable = true;

    users.mutableUsers = lib.mkForce true;
    users.users.root.password = "changeme";

    boot.initrd.systemd.repart = {
      enable = true;
      device = "/dev/vda";
    };
    systemd.repart.partitions = {
      "10-esp" = {
        Type = "esp";
        CopyBlocks = "/dev/disk/by-label/esp-src";
        SizeMinBytes = "96M";
        SizeMaxBytes = "96M";
      };
      "20-root" = {
        Type = "root";
        CopyBlocks = "/dev/disk/by-label/nixos-src";
        Label = "nixos";
      };
    };

    fileSystems."/" = {
      device = "/dev/disk/by-partlabel/nixos";
    };

  };

  installSystem = nixpkgs.lib.nixosSystem {
    system = pkgs.system;
    modules = [
      (modulesPath + "/image/repart.nix")
      (modulesPath + "/profiles/image-based-appliance.nix")
      systemConfig
    ];
  };

in (installSystem.config.system.build.image + "/image.raw")
