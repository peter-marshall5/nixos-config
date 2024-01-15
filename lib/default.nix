{ nixpkgs, agenix, microvm, lanzaboote, ... }:
let

  inherit (nixpkgs) lib;

in

{

  mkNixos = system: hostName:
  let

    cfg = import ../hosts/${hostName}/default.nix;

  in lib.attrsets.nameValuePair hostName (lib.nixosSystem {
    inherit system;

    modules = [
      agenix.nixosModules.default
      lanzaboote.nixosModules.lanzaboote
      microvm.nixosModules.host
      ../modules
      ../hardware/${cfg.hardware}
      {
        ab = cfg; # Abstracted config options
        environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        networking.hostName = lib.mkDefault hostName;
        nixpkgs.hostPlatform = lib.mkDefault system;
      }
      {
        options.ab = {
          hardware = lib.mkOption {
            type = lib.types.str;
          };
        };
      }
    ];

    # (lib.optionals cfg.isServer [ 
    #   srvos.nixosModules.server
    # ]) ++

    # (lib.optionals cfg.isDesktop [
    #   srvos.nixosModules.desktop
    # ]) ++

    # Cross-compiled systems
    # (lib.optional (cfg.buildPlatform != system) {
    #   nixpkgs.config.allowUnsupportedSystem = true;
    #   nixpkgs.buildPlatform.system = cfg.buildPlatform;
    # })

  });

}
