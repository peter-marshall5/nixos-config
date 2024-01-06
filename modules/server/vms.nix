{ config, lib, pkgs, ... }:
let

  vmOpts = { name, config, ... }: {

    options = {

      hypervisor = lib.mkOption {
        default = "firecracker";
        type = lib.types.str;
      };

      hostName = lib.mkOption {
        default = name;
        type = lib.types.str;
      };

      macAddress = lib.mkOption {
        type = lib.types.str;
      };

    };

  };

  defineVm = name: vm: {
    inherit pkgs;
    config = {
      microvm.hypervisor = "${vm.hypervisor}";
      microvm.interfaces = [{
        type = "tap";
        id = "vm-${name}";
        mac = vm.macAddress;
      }];
      networking.hostName = vm.hostName;
      networking.useNetworkd = true;
      systemd.network.enable = true;
      systemd.network.networks."20-lan" = {
        matchConfig.Type = "ether";
        networkConfig = {
          IPv6AcceptRA = true;
          DHCP = "ipv4";
        };
      };
      system.stateVersion = config.system.stateVersion;
    };
  };

in
{

  options.ab.vms = lib.mkOption {
    default = {};
    type = with lib.types; attrsOf (submodule vmOpts);
  };

  config.microvm.vms = builtins.mapAttrs defineVm config.ab.vms;

}
