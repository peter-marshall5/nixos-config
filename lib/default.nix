{ nixpkgs, agenix, microvm, srvos, nixos-veyron-speedy }:
let
  inherit (nixpkgs) lib;
in {
  mkHost = { system, systemConfig ? {}, isServer ? false, isDesktop ? false, hardware, extraModules ? [], hostName, NICs ? [], users ? [], buildPlatform ? ""}:
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
    (lib.optional isDesktop ../modules/desktop.nix) ++
    (lib.optional (hardware == "qemu") ../modules/hardware/qemu.nix) ++
    (lib.optional (hardware == "veyron-speedy") {
      imports = [nixos-veyron-speedy.nixosModules.veyron-speedy];
      boot.swraid.enable = lib.mkDefault false; # Not supported by kernel
    }) ++
    (lib.optional (hardware == "surface-pro-9") ../modules/hardware/surface-pro-9.nix) ++
    (lib.optional (buildPlatform != "") {
      nixpkgs.config.allowUnsupportedSystem = true;
      nixpkgs.buildPlatform.system = buildPlatform;
    }) ++
    extraModules;
  };
}
