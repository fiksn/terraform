{ config, lib, pkgs, ... }: {
  imports = [ <nixpkgs/nixos/modules/virtualisation/digital-ocean-image.nix> ./common.nix ];
  boot.loader.grub.device = "/dev/vda";

  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = "${ip4_gateway}";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="${ip4_address}"; prefixLength=${ip4_cidr}; }
        ];
        ipv4.routes = [ { address = "${ip4_gateway}"; prefixLength = 32; } ];
      };
    };
  };
  
  boot.cleanTmpDir = true;
  networking.firewall.allowPing = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "${ssh_key}"
  ];

  
}

