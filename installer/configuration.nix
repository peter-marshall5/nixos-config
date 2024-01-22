{ config, lib, pkgs, modulesPath, trustedKeys, ... }:

let

  efiArch = pkgs.stdenv.hostPlatform.efiArch;
  kernelPath = "/EFI/Linux/kernel.efi";

in

{

  imports = [
    (modulesPath + "/image/repart.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

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
        SizeMinBytes = "96M";
      };
    };
    "20-root" = {
      storePaths = [ config.system.build.toplevel ];
      repartConfig = {
        Type = "root";
        Format = "squashfs";
        Label = "nixos";
        Minimize = "guess";
      };
    };
  };

  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = [
    "console=ttyS0"
    "loglevel=2"
    "systemd.volatile=overlay"
    "nomodeset"
  ];

  users.mutableUsers = false;
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialHashedPassword = "";
    openssh.authorizedKeys.keys = trustedKeys;
  };
  users.users.root.initialHashedPassword = "";
  services.getty.autologinUser = "nixos";

  security.sudo.wheelNeedsPassword = false;

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/nixos";
    fsType = "squashfs";
  };

  boot.initrd = {
    kernelModules = [ "loop" "overlay" ];
    systemd = {
      enable = true;
      additionalUpstreamUnits = ["systemd-volatile-root.service"];
      storePaths = [
        "${config.boot.initrd.systemd.package}/lib/systemd/systemd-volatile-root"
      ];
    };
  };

  networking.useNetworkd = true;

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = true;
    AuthenticationMethods = "publickey,password";
  };

  environment.systemPackages = with pkgs; [
    e2fsprogs
    btrfs-progs
    cryptsetup
  ];

  system.stateVersion = "24.05";

}
