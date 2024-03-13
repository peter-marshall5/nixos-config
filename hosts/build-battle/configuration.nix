{

  nixpkgs.hostPlatform = "x86_64-linux";

  services.upnpc.enable = true;

  services.minecraft-bedrock-server = {
    enable = true;
    eula = true;
    serverName = " §k::§r §d§lBuild§r  §c§oBattle §k::§r ";
    levelName = "Build Battle v3";
    port = 19133;
    openFirewall = true;
  };

}
