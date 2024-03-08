{
  imports = [
    ./hardware/generic-x86.nix

    ./profiles/base.nix

    ./services/networking/duckdns.nix
    ./services/networking/upnp.nix

    ./virtualisation/vm-runner.nix
    ./virtualisation/microvms
  ];
}
