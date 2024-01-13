{ nixpkgs, agenix, microvm, srvos, nixos-veyron-speedy, lanzaboote, ... }:
let
  inherit (nixpkgs) lib;
  mkHost = { system, systemConfig ? {}, isServer ? false, isDesktop ? false, hardware, extraModules ? [], hostName, NICs ? [], users ? [], buildPlatform ? "", enableSecureBoot ? false}:
  lib.nixosSystem {
    inherit system;
    modules = [{
      imports = [
        agenix.nixosModules.default
        ../modules
      ];

      ab = systemConfig; # Abstracted config options

      environment.systemPackages = [ agenix.packages.x86_64-linux.default ];

      networking.hostName = hostName;

      nixpkgs.hostPlatform = lib.mkDefault system;
    }] ++
    (lib.optional isServer {
      imports = [
        ../modules/server
        microvm.nixosModules.host
        srvos.nixosModules.server
      ];
      ab.wan.interfaces = NICs;
    }) ++
    (lib.optional isDesktop {
      imports = [
        ../modules/desktop.nix
        srvos.nixosModules.desktop
      ];
    }) ++
    (lib.optional (hardware == "qemu") ../modules/hardware/qemu.nix) ++
    (lib.optional (hardware == "veyron-speedy") {
      imports = [nixos-veyron-speedy.nixosModules.veyron-speedy];
      boot.swraid.enable = lib.mkDefault false; # Not supported by kernel
    }) ++
    (lib.optional (hardware == "surface-pro-9") ../modules/hardware/surface-pro-9) ++
    (lib.optional (buildPlatform != "") {
      nixpkgs.config.allowUnsupportedSystem = true;
      nixpkgs.buildPlatform.system = buildPlatform;
    }) ++
    (lib.optional enableSecureBoot {
      imports = [lanzaboote.nixosModules.lanzaboote];
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    }) ++
    extraModules;
  };
in {
  defineHosts = hosts: {
    nixosConfigurations = builtins.listToAttrs (builtins.map (
      host: lib.attrsets.nameValuePair "${host.hostName}" (mkHost host)
    ) hosts);
  };
}
