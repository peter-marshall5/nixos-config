{
  system = "x86_64-linux";
  hardware = "generic";
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
  net.bridge.interfaces = ["enp1s0f1"];
  users = [ "petms" ];
  cloudflare = {
    enable = true;
    tunnelId = "c7f932c2-213b-4cca-9e6e-87052a5a849a";
    ssh.domain = "console.opcc.tk";
  };
  ddns = {
    enable = true;
    domains = [ "opcc" ];
  };
  vms = {
    enable = true;
    guests.petms = {
      memory = "4G";
      diskSize = "100g";
      cpus = 2;
      os = "nixos";
    };
    guests.cheesecraft = {
      memory = "500M";
      diskSize = "40g";
      cpus = 1;
      os = "nixos";
    };
  };
}
