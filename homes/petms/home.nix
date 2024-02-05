{ config, pkgs, sshAliases, ... }:

{
  home.username = "petms";
  home.homeDirectory = "/home/petms";

  home.stateVersion = "23.11";
  
  home.packages = with pkgs; [
    nushell
    helix
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
      theme = "catppuccin_frappe";
      editor.true-color = true;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = sshAliases;
  };

  programs.git = {
    enable = true;
    userEmail = "petms@proton.me";
    userName = "Peter Marshall";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
