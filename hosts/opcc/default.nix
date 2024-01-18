{
  hardware = "generic";
  fs.root.uuid = "f7086f18-40c4-462b-9b79-bcc522a2f6ce";
  fs.root.luksUuid = "388cf94a-5063-41ec-8830-1b62b506fe47";
  fs.esp.uuid = "64C1-9B6E";
  net.bridge.enable = true;
  net.bridge.interfaces = ["enp1s0f1"];
  hypervisor.enable = true;
  hypervisor.guests = {
    petms = {
      memory = "2G";
      diskSize = "100g";
      cpus = 2;
      os = "nixos";
      macAddress = "02:00:00:00:00:01";
    };
  };
}
