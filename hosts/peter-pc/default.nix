{
  system = "x86_64-linux";
  hardware = "surface-pro-9";
  desktop.enable = true;
  secureboot.enable = true;
  fs.fs = rec {
    root = {
      uuid = "c131240c-ff03-467c-b518-f5e435ac38a0";
      luks.uuid = "6d738085-91c8-457d-b3d9-1c507c7ce6f2";
    };
    home.uuid = root.uuid;
    nix.uuid = root.uuid;
    boot.uuid = "ED65-FF95";
  };
  fs.boot.lvm.enable = true;
}
