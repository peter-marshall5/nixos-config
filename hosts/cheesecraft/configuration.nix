{

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "cheesecraft";

  services.upnpc.enable = true;

  services.minecraft-bedrock-server = {
    enable = true;
    eula = true;
    serverName = "§k::§r §eCheese§bcraft§f - §aSurvival§r §k::§r ";
    levelName = "Cheesecraft Season 4";
    port = 19132;
    openFirewall = true;
  };

}
