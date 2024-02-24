{ config, lib, pkgs, ... }: {

  imports = [ ./minecraft.nix ];

  virtualisation.memorySize = 2048;

}
