{ config, lib, pkgs, modulesPath, ... }: let
  cfg = config.virtualisation.microvms;

  hostPlatform = config.nixpkgs.hostPlatform;
  stateVersion = config.system.stateVersion;

  mkSystem = name: spec@{ config
  , forwardPorts
  , macAddress
  , localAddress
  , localAddress6
  , debug
  }: spec // { system = lib.nixosSystem { modules = [
    ../../modules
    ./vm-config.nix
    (modulesPath + "/virtualisation/qemu-vm.nix")
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/perlless.nix")
    config
    {
      nixpkgs.hostPlatform = hostPlatform;
      system.stateVersion = stateVersion;
      networking.hostName = name;

      system.etc.overlay.mutable = lib.mkDefault false;
      users.mutableUsers = lib.mkDefault false;
      users.allowNoPasswordLogin = true;
      environment.etc."machine-id".text = " ";

      virtualisation = {
        writableStore = false;
        diskImage = "${toString cfg.stateDir}/${name}/state.img";
        qemu.networkingOptions = lib.mkForce [
          "-nic tap,mac=${macAddress},ifname=vm-${name},br=${cfg.bridge},model=virtio,script=no,downscript=no"
        ];
      };

      systemd.network.networks."10-lan" = {
        name = "en*";
        address = [ "${localAddress}/24" "${localAddress6}/64" ];
        routes = [{
          routeConfig.Gateway = "${cfg.address}";
        }];
      };

      networking.useDHCP = false;

      services.journald.upload = {
        enable = true;
        settings = {
          Upload.URL = "http://${cfg.address}";
        };
      };
    }
    (lib.optionalAttrs debug {
      # Create a default user for debugging.
      users.users."nixos" = {
        isNormalUser = true;
        initialPassword = "nixos";
        group = "nixos";
        useDefaultShell = true;
        extraGroups = [ "wheel" ];
      };
      users.groups."nixos" = {};

      # Allow serial login for debugging.
      systemd.services."serial-getty@ttyS0".enable = true;
      systemd.services."autovt@".enable = lib.mkForce true;

      services.openssh.settings.PasswordAuthentication = true;
    })
  ]; }; inherit name; };
  

  vmSystems = lib.mapAttrsToList mkSystem config.microvms;

  mkSystemPorts = {
    system
  , localAddress
  , localAddress6
  , ... }: builtins.concatLists (lib.mapAttrsToList (proto: map (port: {
    inherit proto port;
    address = "${localAddress}";
    address6 = "${localAddress6}";
  })) (with system.config.networking.firewall; {
    "tcp" = allowedTCPPorts;
    "udp" = allowedUDPPorts;
  }));

  ports = builtins.concatMap mkSystemPorts (builtins.filter (vm: vm.forwardPorts) vmSystems);

in {

  options.virtualisation.microvms = {
    enable = lib.mkEnableOption (lib.mdDoc ''
      Run microVMs
    '');
    uplink = lib.mkOption {
      default = "lo";
      type = lib.types.str;
    };
    bridge = lib.mkOption {
      default = "virbr0";
      type = lib.types.str;
    };
    address = lib.mkOption {
      default = "10.0.100.1";
      type = lib.types.str;
    };
    address6 = lib.mkOption {
      default = "fc00::1";
      type = lib.types.str;
    };
    stateDir = lib.mkOption {
      default = "/var/lib/microvms";
    };
  };

  options.microvms = lib.mkOption {
    default = {};
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        config = lib.mkOption {
          type = lib.types.attrs;
        };
        forwardPorts = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        macAddress = lib.mkOption {
          type = lib.types.str;
        };
        localAddress = lib.mkOption {
          type = lib.types.str;
        };
        localAddress6 = lib.mkOption {
          type = lib.types.str;
        };
        debug = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
    });
  };

  config = lib.mkIf cfg.enable {

    systemd.services = builtins.listToAttrs (map ({ name, system, ... }: let
      preStartScript = pkgs.writeShellApplication {
        name = "pre-start";
        runtimeInputs = [ ];
        text = ''
          [ -e ${toString cfg.stateDir} ] || mkdir -p ${toString cfg.stateDir}
          [ -e ${toString cfg.stateDir}/${name} ] || ${pkgs.btrfs-progs}/bin/btrfs subvolume create ${toString cfg.stateDir}/${name}
        '';
      };
    in lib.nameValuePair "microvm-${name}" {
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      script = "exec ${system.config.system.build.vm}/bin/${system.config.system.build.vm.meta.mainProgram}";
      serviceConfig = {
        ExecStartPre = [ "${preStartScript}/bin/pre-start" ];
      };
    }) vmSystems);

    systemd.network.netdevs."20-bridge" = {
      netdevConfig = {
        Name = cfg.bridge;
        Kind = "bridge";
      };
    };
    systemd.network.networks."20-bridge" = {
      name = cfg.bridge;
      address = [ "${cfg.address}/24" "${cfg.address6}/64" ];
      bridgeConfig = {
        Isolated = false;
        Learning = false;
      };
    };

    systemd.network.networks."20-bridge-vms" = {
      name = "vm-*";
      bridge = [ cfg.bridge ];
      bridgeConfig.Isolated = true;
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ cfg.bridge ];
      externalInterface = cfg.uplink;
      enableIPv6 = true;
    };

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
      interfaces."${cfg.bridge}".allowedTCPPorts = [ 19532 ];
    };

    networking.hosts = builtins.listToAttrs (builtins.concatMap ({ localAddress, localAddress6, name, ... }: [
      (lib.nameValuePair "${localAddress}" [ name ])
      (lib.nameValuePair "${localAddress6}" [ name ])
    ]) vmSystems);

    services.journald.remote = {
      enable = true;
      listen = "http";
      port = 19532;
    };

  };

}
