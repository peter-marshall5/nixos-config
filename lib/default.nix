{ nixpkgs, agenix, microvm, srvos }:
let
  inherit (nixpkgs) lib;
in {
  host.defineHost = { system, systemConfig ? {}, isServer ? false, isQemuGuest ? false, extraModules ? [], hostName, NICs ? [], users ? []}:
  let
    defineSystemUser = { name, admin }:
    { pkgs, ...}: {
      users.users."${name}" = {
        isNormalUser = true;
        extraGroups = (if admin then [ "wheel" ] else []);
        openssh.authorizedKeys.keys = import ../ssh-keys.nix "";
        shell = pkgs.nushell;
      };
    };
  in lib.nixosSystem {
    inherit system;
    modules = [
      agenix.nixosModules.default
      {
        imports = [
          ../modules
        ] ++ (map (u: defineSystemUser u) users);

        ab = systemConfig; # Abstracted config options

        environment.systemPackages = [ agenix.packages.x86_64-linux.default ];

        networking.hostName = hostName;

        nixpkgs.hostPlatform = lib.mkDefault system;
      }
    ] ++
    (if isServer then 
      [
        ../modules/server
        microvm.nixosModules.host
        srvos.nixosModules.server
        { ab.wan.interfaces = NICs; }
      ]
    else []
    ) ++
    (if isQemuGuest then [../modules/hardware/qemu.nix] else []) ++ extraModules;
  };
}
