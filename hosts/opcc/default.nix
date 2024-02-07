{
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
  ddns = {
    enable = true;
    protocol = "cloudflare";
    domains = [ "svc.opcc.tk" ];
  };
  ssh.address = "svc.opcc.tk";
  ssh.port = 2200;
  net.upnp.enable = true;
  vms.enable = true;
  vms.guests = [ "petms" "cheesecraft" ];
}
