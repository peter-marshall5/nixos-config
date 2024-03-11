{ config, lib, pkgs, ... }: {

  imports = [ ./minecraft.nix ];

  virtualisation.vmVariant.config = {
    virtualisation.memorySize = 2048;
  };

}
