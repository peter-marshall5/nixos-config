{ config, lib, pkgs, ... }: {

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.systemd.enable = true;
  system.etc.overlay.mutable = false;

  systemd.enableEmergencyMode = lib.mkDefault false;
  systemd.watchdog = {
    runtimeTime = "10s";
    rebootTime = "30s";
  };

  users.mutableUsers = false;
  users.allowNoPasswordLogin = true;

  # Allow login on serial and tty.
  systemd.services."serial-getty@ttyS0".enable = true;

  # Create a default user for debugging.
  users.users."nixos" = {
    isNormalUser = true;
    initialPassword = "nixos";
    group = "nixos";
    useDefaultShell = true;
    extraGroups = [ "wheel" ];
  };
  users.groups."nixos" = {};

  virtualisation.vmVariant.config.virtualisation = {
    memorySize = lib.mkDefault 256;
    cores = lib.mkDefault 1;

    diskSize = lib.mkDefault 2048;

    writableStore = false;
  };

}
