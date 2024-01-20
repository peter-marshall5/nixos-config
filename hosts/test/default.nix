{
  system = "x86_64-linux";
  hardware = "virt";
  users = [ "petms" ];
  fs.fs = {
    root = {
      fsType = "virtio";
      device = "root";
    };
  };
}
