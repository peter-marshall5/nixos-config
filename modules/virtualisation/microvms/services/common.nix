{ config, lib, pkgs, ... }: {

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.systemd.enable = true;
  system.etc.overlay.mutable = lib.mkDefault false;

  systemd.enableEmergencyMode = lib.mkDefault false;
  systemd.watchdog = {
    runtimeTime = "10s";
    rebootTime = "30s";
  };

  users.mutableUsers = lib.mkDefault false;
  users.allowNoPasswordLogin = true;

  environment.etc."machine-id".text = " ";

  # Allow serial login for debugging.
  systemd.services."serial-getty@ttyS0".enable = true;
  systemd.services."autovt@".enable = lib.mkForce true;

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
