{
  hardware = "virt";
  net.bridge = {
    enable = true;
    interfaces = ["ens2"];
  };
  fs.root.uuid = "6ac99c27-da1c-421f-90b0-127225b34f5d";
  fs.esp.uuid = "7839-D16C";
  cloudflare = {
    enable = true;
    tunnelId = "ada56c81-89c9-403b-8d18-c20c39ab973c";
    ssh.domain = "ssh-petms.opcc.tk";
  };
  duckdns = {
    enable = true;
    domains = [ "petms-opcc" ];
  };
}
