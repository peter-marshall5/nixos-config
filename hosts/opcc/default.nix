{
  hardware = "generic";
  fs.root.uuid = "f7086f18-40c4-462b-9b79-bcc522a2f6ce";
  fs.root.luksUuid = "388cf94a-5063-41ec-8830-1b62b506fe47";
  fs.home.onRoot = true;
  fs.esp.uuid = "64C1-9B6E";
  #vms = [self.nixosConfigurations.petms];
}
