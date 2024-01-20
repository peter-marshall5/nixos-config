{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    agenix.url = "github:ryantm/agenix";
    nixos-veyron-speedy.url = "github:peter-marshall5/nixos-veyron-speedy";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs:
  let
    util = (import ./lib) inputs;
    inherit (util) mkHosts;
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    nixosConfigurations = mkHosts [
      "opcc"
      "petms"
      "peter-pc"
    ];
    devShells.x86_64-linux.surface-kernel = (pkgs.callPackage ./hardware/surface-pro-9/kernel.nix {
      baseKernel = pkgs.linux_latest;
    }).overrideAttrs (o: {nativeBuildInputs=o.nativeBuildInputs ++ (with pkgs; [ pkg-config ncurses ]);});
    packages.x86_64-linux.installer = pkgs.callPackage ./modules/hypervisor/installer.nix {
      inherit (inputs) nixpkgs;
      modulesPath = (inputs.nixpkgs + "/nixos/modules");
    };
  };
}
