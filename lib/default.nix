{ nixpkgs }:
{
  host.defineHost = { system, isServer, extraModules, hostName, NICs ? []}:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          ./common.nix
          ../hosts/${hostName}/configuration.nix
          {
            networking.hostName = hostName;
            networking.wan.interfaces = NICs;
          }
        ] ++
        (if isServer then [
          ./server.nix
        ] else [
          ./desktop.nix
        ]) ++ extraModules;
    };
  modules = {
    ddns = ./ddns.nix;
  };
}
