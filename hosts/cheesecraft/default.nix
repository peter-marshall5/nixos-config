{
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
}