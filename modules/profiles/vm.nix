{ config, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/perlless.nix")
    ../virtualisation/qemu-vm-integration.nix
  ];

  virtualisation = {
    memorySize = lib.mkDefault 256;
    cores = lib.mkDefault 1;

    diskSize = lib.mkDefault 2048;

    writableStore = false;
    useDefaultFilesystems = false;
    fileSystems = {
      "/" = {
        device = "/dev/vda";
        fsType = "btrfs";
        autoResize = true;
        autoFormat = true;
      };
    };
    qemu.diskInterface = "virtio";

    qemu.package = config.virtualisation.host.pkgs.qemu_test;
    qemu.guestAgent.enable = false;

    graphics = false;
  };

  # Allow perl to be pulled in by other packages
  system.forbiddenDependenciesRegex = lib.mkForce "";

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

  networking.interfaces."e*".ipv6.addresses = [{
    address = config.networking.ip;
    prefixLength = 48;
  }];

  services.journald.upload = {
    enable = true;
    settings = {
      Upload.URL = "http://[fe80::68dd:e8ff:fef5:c932%eth0]";
    };
  };
}
