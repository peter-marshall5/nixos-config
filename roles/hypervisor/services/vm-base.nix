{ config, lib, pkgs, modulesPath, ... }: {

  imports = [
    (modulesPath + "/image/repart.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  image.repart = {
    name = "image";
    partitions = {
      "10-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "ext4";
          Minimize = "guess";
          MakeDirectories = "/home /etc /var";
        };
      };
    };
  };

}
