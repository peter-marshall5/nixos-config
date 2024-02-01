{ config, lib, ... }:

{

  options.ab.net.networkmanager = {

    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };

    useIwd = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };

  };

  config = lib.mkIf config.ab.net.networkmanager.enable (lib.mkMerge [{

    networking.networkmanager.enable = true;

  } (lib.mkIf config.ab.net.networkmanager.useIwd {

    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

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

  })]);

}
