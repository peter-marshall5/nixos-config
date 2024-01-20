{
  system = "x86_64-linux";
  hardware = "virt";
  users = [ "petms" ];
  net.bridge = {
    enable = true;
    interfaces = ["ens2"];
  };
  fs.root.uuid = "6ac99c27-da1c-421f-90b0-127225b34f5d";
  fs.esp.uuid = "7839-D16C";
  cloudflare = {
    enable = true;
    tunnelId = "24eb600a-ff9a-419d-bf8f-fc06df91207f";
    ssh.domain = "ssh-petms.opcc.tk";
  };
  duckdns = {
    enable = true;
    domains = [ "petms-opcc" ];
  };
  vms.enable = true;
  vms.vms = {
    test = {
      cpus = 1;
      memory = "512M";
    };
  };
}
