{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    agenix.url = "github:ryantm/agenix";
    nixos-veyron-speedy.url = "github:peter-marshall5/nixos-veyron-speedy";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    installer.url = "github:peter-marshall5/nixos-installer";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs = inputs:
  let
    util = (import ./lib) inputs;
    inherit (util) mkHosts mkHomes;
  in
  {
    nixosConfigurations = mkHosts {
      opcc = {
        hardware = "generic-x86";
        role = "hypervisor";
        net.ddns.duckdns.enable = true;
        users = [ "petms" ];
        services.vms = {
          minecraft = {
            config.worlds = (import ./minecraft-servers.nix);
          };
        };
        vms.guests = {
          john = {
            memory = "1G";
            threads = 1;
            mac = "C1:BF:7F:05:08:50";
          };
        };
        ssh.port = 2200;
      };
      petms = {
        hardware = "virt";
        host = "opcc";
        threads = 2;
        memory = "2G";
        mac = "0E:A8:8E:D5:10:F0";
        role = "dev";
        users = [ "petms" ];
        ssh.port = 2273;
      };
      peter-pc = {
        hardware = "surface-pro-9";
        role = "desktop";
        users = [ "petms" ];
        desktop.autologin.user = "petms";
      };
    };
    deploy.nodes.opcc = {
      hostname = "opcc";
      remoteBuild = false;
      profiles.system = {
        sshUser = "petms";
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.opcc;
      };
    };
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks inputs.self.deploy) inputs.deploy-rs.lib;
    homeConfigurations = mkHomes [ "petms" "petms@peter-pc" ];
    devShells.x86_64-linux.surface-kernel = let
     pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    in (pkgs.callPackage ./hardware/surface-pro-9/kernel {
      baseKernel = pkgs.linux_latest;
    }).overrideAttrs (o: {nativeBuildInputs=o.nativeBuildInputs ++ (with pkgs; [ pkg-config ncurses ]);});
  };
}
