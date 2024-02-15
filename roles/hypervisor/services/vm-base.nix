{ config, lib, pkgs, modulesPath, ... }: {

  imports = [
    (modulesPath + "/image/repart.nix")
    (modulesPath + "/profiles/minimal.nix")
    (modulesPath + "/profiles/headless.nix")
  ];

  image.repart = {
    name = "image";
    partitions = {
      "10-root" = {
        storePaths = [ config.system.build.toplevel ];
        repartConfig = {
          Type = "root";
          Format = "erofs";
          Minimize = "guess";
          MakeDirectories = "/home /etc /var";
        };
      };
    };
  };

}
