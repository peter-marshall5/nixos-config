{ config, ... }: {

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.availableKernelModules = [ "ahci" "sd_mod" "uas" "usb_storage" ];

  boot.kernelModules = [ "kvm_amd" ];

  hardware.enableRedistributableFirmware = true;

  hardware.cpu.amd.updateMicrocode = true;

  boot.initrd.kernelModules = [ "efi_pstore" "efivarfs" ];

  boot.swraid.enable = true;

  fileSystems."/" = {
    fsType = "btrfs";
    options = [ "subvol=@" ];
    device = "/dev/mapper/root";
    encrypted = {
      enable = true;
      label = "root";
      blkDev = "/dev/md127";
      keyFile = "/sys/firmware/efi/efivars/EncKey-b77c97b7-23f5-406d-b86b-15a9216fd71f";
    };
  };

  fileSystems."/home" = {
    inherit (config.fileSystems."/") device fsType;
    options = [ "subvol=@home" ];
  };

  fileSystems."/nix" = {
    inherit (config.fileSystems."/") device fsType;
    options = [ "subvol=@nix" ];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/61F4-656B";
    fsType = "vfat";
  };

}
