{
  hardware = "virt";
  net.bridge = {
    enable = true;
    interfaces = ["ens2"];
  };
  fs.root.uuid = "041bc940-7256-453e-b582-6e4688141836";
  fs.esp.uuid = "06B3-42DD";
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
