{ nixpkgs, agenix, microvm, srvos, nixos-appliance }:
let
  inherit (nixpkgs) lib;
in {
  host.defineHost = { system, systemConfig ? {}, isServer ? false, hardware, extraModules ? [], hostName, NICs ? [], users ? [], appliance ? false}:
  let
    defineSystemUser = { name, admin, hashedPassword ? "" }:
    { pkgs, ... }: {
      users.users."${name}" = {
        isNormalUser = true;
        extraGroups = lib.mkIf admin [ "wheel" ];
        openssh.authorizedKeys.keys = import ../ssh-keys.nix "";
        shell = lib.mkIf (!appliance) pkgs.nushell;
        hashedPassword = lib.mkIf (hashedPassword != "") hashedPassword;
      };
    };
  in lib.nixosSystem {
    inherit system;
    modules = [{
      imports = [
        agenix.nixosModules.default
        ../modules
      ] ++ (map (u: defineSystemUser u) users);

      ab = systemConfig; # Abstracted config options

      environment.systemPackages = [ agenix.packages.x86_64-linux.default ];

      networking.hostName = hostName;

      boot.swraid.enable = lib.mkDefault false;

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
    (lib.optional hardware.qemu ../modules/hardware/qemu.nix) ++
    (lib.optional appliance {
      imports = [
        nixos-appliance.nixosModules.appliance-image
        (nixpkgs + "/nixos/modules/profiles/image-based-appliance.nix")
      ];
      ab.fs.enable = false;
      ab.autoUpgrade = false;
    }) ++
    extraModules;
  };
}
