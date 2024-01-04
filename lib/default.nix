{ nixpkgs, agenix, microvm, srvos }:
let
  inherit (nixpkgs) lib;
in {
  host.defineHost = { system, systemConfig ? {}, isServer ? false, isQemuGuest ? false, extraModules ? [], hostName, NICs ? []}:
  lib.nixosSystem {
    inherit system;
    modules = [
      agenix.nixosModules.default
      {
        imports = [ ../hosts/${hostName}/configuration.nix ../modules/system ];

        ab = systemConfig; # Abstracted config options

        environment.systemPackages = [ agenix.packages.x86_64-linux.default ];

        networking.hostName = hostName;

        nixpkgs.hostPlatform = system;
      }
    ] ++
    (if isServer then 
      [
        ../modules/system/server
        microvm.nixosModules.host
        srvos.nixosModules.server
        {
          ab.wan.interfaces = NICs;
          ab.hardware.qemu = isQemuGuest;
        }
      ]
    else []
    );
  };
}
