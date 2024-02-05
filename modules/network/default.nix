{

  imports = [
    ./bridge
    ./networkmanager.nix
  ];

  networking.firewall.enable = true;
  networking.nftables.enable = true;

}
