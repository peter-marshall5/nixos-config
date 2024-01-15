{
  hardware = "virt";
  net.bridge = {
    enable = true;
    interfaces = ["ens2"];
  };
  fs.root.uuid = "e347fbee-252a-4420-a636-5ae21e56f8dd";
  fs.home.uuid = "2a1bb819-57fd-4afc-8caa-f5a36b04ac9f";
  fs.home.luksUuid = "6f8aeabf-bc90-4b93-ae89-2fc75fafeabe";
  fs.esp.uuid = "2430-B4AF";
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
