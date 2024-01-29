{
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
}
