{
  imports = [
    ./hardware/generic-x86.nix
    ./hardware/surface-pro-9

    ./profiles/base.nix

    ./services/networking/duckdns.nix
    ./services/networking/upnp.nix

    ./services/display-managers/greetd.nix

    ./virtualisation/vm-runner.nix
    ./virtualisation/microvms
  ];
}
