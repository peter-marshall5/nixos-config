{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    agenix.url = "github:ryantm/agenix";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-veyron-speedy.url = "github:peter-marshall5/nixos-veyron-speedy";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs:
  let
    util = (import ./lib) inputs;
    inherit (util) mkNixos;
  in
  {
    nixosConfigurations = builtins.listToAttrs [
      (mkNixos "x86_64-linux" "opcc")
      (mkNixos "x86_64-linux" "petms")
      (mkNixos "x86_64-linux" "peter-pc")
    ];
  };
}
