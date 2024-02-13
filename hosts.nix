{ self, ... }: {

  opcc = {
    system = "x86_64-linux";
    hardware = "generic";
    autoUpgrade = false;
    secureboot.enable = true;
    fs.luks.enable = true;
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
    ssh.address = "opcc.duckdns.org";
    ssh.port = 2202;
    net.upnp.enable = true;
    services.mcbe.enable = true;
    services.mcbe.servers = (import ./minecraft-servers.nix);
  };

  peter-pc = {
    system = "x86_64-linux";
    hardware = "surface-pro-9";
    desktop.enable = true;
    users = [ "petms" ];
    desktop.autologin.user = "petms";
  };

  petms = {
    system = "x86_64-linux";
    hardware = "virt";
    users = [ "petms" ];
    net.bridge = {
      enable = true;
      interfaces = ["ens2"];
    };
    ssh.address = "opcc.duckdns.org";
    ssh.port = 2201;
    net.upnp.enable = true;
  };

}
