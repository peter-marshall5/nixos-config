{ nixpkgs, agenix, microvm, srvos, nixos-veyron-speedy, lanzaboote, ... }:
let

  inherit (nixpkgs) lib;

  mkHost = { system, systemConfig ? {}, isServer ? false, isDesktop ? false, hardware, extraModules ? [], hostName, NICs ? [], users ? [], buildPlatform ? "", enableSecureBoot ? false}:
  let

    hardwareProfiles = {
      "virt" = ../modules/hardware/virt.nix;
      "surface-pro-9" = ../modules/hardware/surface-pro-9;
      "generic" = ../modules/hardware/generic.nix;
    };

  in lib.nixosSystem {
    inherit system;

    modules = [
      agenix.nixosModules.default
      ../modules
      hardwareProfiles."${hardware}"
      {
        ab = systemConfig; # Abstracted config options
        environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        networking.hostName = hostName;
        nixpkgs.hostPlatform = lib.mkDefault system;
      }
    ] ++

    (lib.optionals isServer [
      ../modules/server
      microvm.nixosModules.host
      srvos.nixosModules.server
      {
        ab.wan.interfaces = NICs;
      }
    ]) ++

    (lib.optionals isDesktop [
      ../modules/desktop.nix
      srvos.nixosModules.desktop
    ]) ++

    (lib.optional (buildPlatform != "") {
      nixpkgs.config.allowUnsupportedSystem = true;
      nixpkgs.buildPlatform.system = buildPlatform;
    }) ++

    (lib.optionals enableSecureBoot [
      lanzaboote.nixosModules.lanzaboote
      {
        boot.loader.systemd-boot.enable = lib.mkForce false;
        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/etc/secureboot";
        };
      }
    ]) ++ extraModules;

  };

in {
  defineHosts = hosts: {
    nixosConfigurations = builtins.listToAttrs (builtins.map (
      host: lib.attrsets.nameValuePair "${host.hostName}" (mkHost host)
    ) hosts);
  };
}
