{ config, lib, pkgs, ... }: {

  imports = [ ./minecraft.nix ];

  virtualisation.vmVariant.config = {
    virtualisation.memorySize = 2048;
  };

  services.upnpc.enable = true;

  # Perl is required by podman
  system.forbiddenDependenciesRegex = lib.mkForce "";

  # Mutable /etc is required by podman
  system.etc.overlay.mutable = true;
  users.mutableUsers = true;

  system.stateVersion = "24.05";

}
