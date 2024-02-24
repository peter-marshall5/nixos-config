{

  hardware.surface-pro-9.enable = true;

  time.timeZone = "America/Toronto";

  console.keyMap = "us";

  networking.wireless.iwd.settings = {
    General = {
      Country = "CA";
      # Prevent tracking across networks
      AddressRandomization = "network";
    };
    Rank = {
      # Prefer faster bands
      BandModifier2_4GHz = 1.0;
      BandModifier5GHz = 3.0;
      BandModifier6GHz = 10.0;
    };
  };

  fileSystems."/" = {
    device = "/dev/mapper/root";
    encrypted = {
      enable = true;
      label = "root";
      blkDev = "/dev/vg0/lv0";
    };
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  boot.initrd.services.lvm.enable = true;

  security.tpm2.enable = true;

  zramSwap.enable = true;

  xdg.portal.wlr.enable = true;

  services.greetd.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "petms";

}
