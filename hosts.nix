{ self, ... }: {

  opcc = {
    system = "x86_64-linux";
    hardware = "generic";
    autoUpgrade = false;
    secureboot.enable = true;
    fs.fs = rec {
      root = {
        uuid = "f7086f18-40c4-462b-9b79-bcc522a2f6ce";
        luks.uuid = "388cf94a-5063-41ec-8830-1b62b506fe47";
      };
      nix.uuid = root.uuid;
      home.uuid = root.uuid;
      boot.uuid = "64C1-9B6E";
    };
    net.bridge.enable = true;
    net.bridge.interfaces = [ "enp2s0f1" ];
    users = [ "petms" ];
    ddns.duckdns = {
      enable = true;
      domains = [ "opcc" ];
    };
    ssh.address = "opcc.duckdns.org";
    ssh.port = 2200;
    net.upnp.enable = true;
    vms.enable = true;
    vms.guests = [ "petms" "cheesecraft" ];
  };

  cheesecraft = {
    system = "x86_64-linux";
    hardware = "virt";
    users = [ "petms" ];
    net.bridge = {
      enable = true;
      interfaces = ["ens2"];
    };
    fs.fs = rec {
      root.uuid = "782e59f1-1a9f-472b-877c-3d15bf36a72a";
      nix.uuid = root.uuid;
      home.uuid = root.uuid;
      boot.uuid = "6F1E-4DDF";
    };
    ssh.address = "opcc.duckdns.org";
    ssh.port = 2202;
    net.upnp.enable = true;
    services.mcbe.enable = true;
    services.mcbe.servers = {
      cheesecraft = {
        port = 19134;
        title = "§k::§r §eCheese§bcraft§f - §aSurvival§r §k::§r ";
        levelName = "Cheesecraft Season 4";
      };
      build-battle = {
        port = 19133;
        title = " §k::§r §d§lBuild§r  §c§oBattle §k::§r ";
        levelName = "Build Battle v3";
      };
    };
  };

  peter-pc = {
    system = "x86_64-linux";
    hardware = "surface-pro-9";
    desktop.enable = true;
    users = [ "petms" ];
    desktop.autologin.user = "petms";
    secureboot.enable = true;
    fs.fs = rec {
      root = {
        uuid = "f8a050ce-76d3-430a-a734-00bed678aeb6";
        luks.uuid = "990ec395-607a-4df8-b8a4-7680f27f4ecf";
      };
      home.uuid = root.uuid;
      nix.uuid = root.uuid;
      boot.uuid = "940E-785F";
    };
  };

  petms = {
    system = "x86_64-linux";
    hardware = "virt";
    users = [ "petms" ];
    net.bridge = {
      enable = true;
      interfaces = ["ens2"];
    };
    fs.fs = rec {
      root.uuid = "6ac99c27-da1c-421f-90b0-127225b34f5d";
      nix.uuid = root.uuid;
      home.uuid = root.uuid;
      boot.uuid = "7839-D16C";
    };
    ssh.address = "opcc.duckdns.org";
    ssh.port = 2201;
    net.upnp.enable = true;
  };

}
