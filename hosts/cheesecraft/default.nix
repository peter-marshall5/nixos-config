{
  system = "x86_64-linux";
  hardware = "virt";
  users = [ "petms" ];
  net.bridge = {
    enable = true;
    interfaces = ["ens2"];
  };
  fs.fs = rec {
    root.uuid = "bebde0fb-60d8-43ac-8c37-2dee847a2cfe";
    nix.uuid = root.uuid;
    home.uuid = root.uuid;
    boot.uuid = "7C5D-1030";
  };
}
