{ nixpkgs, agenix, microvm, srvos }:
{
  host.defineHost = { system, isServer, extraModules, hostName, NICs ? []}:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules =
        [
          ./common.nix
          ../hosts/${hostName}/configuration.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
            networking.hostName = hostName;
            networking.wan.interfaces = NICs;
          }
        ] ++
        (if isServer then [
          ./server.nix
          microvm.nixosModules.host
          srvos.nixosModules.server
        ] else [
          ./desktop.nix
        ]) ++ extraModules;
    };
  modules = {
    ddns = ./ddns.nix;
  };
}
