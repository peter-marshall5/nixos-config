{ config, pkgs, sshAliases, ... }:

{
  home.username = "petms";
  home.homeDirectory = "/home/petms";

  home.stateVersion = "23.11";
  
  home.packages = with pkgs; [
    miniupnpc
    arp-scan
  ];

  programs.nushell = {
    enable = true;
    configFile.source = dotfiles/nushell/config.nu;
    envFile.source = dotfiles/nushell/env.nu;
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "zed_onedark";
      editor.true-color = true;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = sshAliases;
    addKeysToAgent = "1h";
  };

  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;
    userEmail = "petms@proton.me";
    userName = "Peter Marshall";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
