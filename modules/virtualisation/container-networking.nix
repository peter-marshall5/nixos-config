{ config, lib, pkgs, ... }: let
  cfg = config.virtualisation.networking;

  containers = lib.filterAttrs (name: c: c.privateNetwork) config.containers;

  getAddress = ip: lib.elemAt (lib.splitString "/" ip) 0;

  mkPorts = name: {
    config
  , localAddress
  , localAddress6
  , ... }: builtins.concatLists (lib.mapAttrsToList (proto: map (port: {
    inherit proto port;
    address = getAddress localAddress;
    address6 = getAddress localAddress6;
  })) (with config.networking.firewall; {
    "tcp" = allowedTCPPorts;
    "udp" = allowedUDPPorts;
  }));

  ports = builtins.concatLists (lib.mapAttrsToList mkPorts containers);

in {

  options.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ config, ... }: {
      config = lib.mkIf config.privateNetwork {
        hostBridge = cfg.bridge;
        hostAddress = getAddress cfg.address;
        hostAddress6 = getAddress cfg.address6;
        config = {
          networking.useHostResolvConf = false;
        };
      };
    }));
  };

  config = lib.mkIf (containers != {}) {

    assertions = [{
      assertion = config.boot.enableContainers;
    } {
      assertion = config.virtualisation.networking.enable;
    }];

    networking.nat.forwardPorts = builtins.concatMap (port: [
      {
        destination = "${port.address}:${toString port.port}";
        inherit (port) proto;
        sourcePort = port.port;
      }
      {
        destination = "[${port.address6}]:${toString port.port}";
        inherit (port) proto;
        sourcePort = port.port;
      }
    ]) ports;

    networking.firewall = {
      allowedTCPPorts = map (p: p.port) (builtins.filter (p: p.proto == "tcp") ports);
      allowedUDPPorts = map (p: p.port) (builtins.filter (p: p.proto == "udp") ports);
    };

  };

}
