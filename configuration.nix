{ config, lib, pkgs, ... }:
let 
  has_ip6 = lib.stringLength "${ip6_address}" > 2;
in
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/digital-ocean-image.nix> ./common.nix ];
  boot.loader.grub.device = "/dev/vda";

  networking = {
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    defaultGateway = "${ip4_gateway}";
    defaultGateway6 = if has_ip6 then "${ip6_gateway}" else "";

    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
  };

  boot.cleanTmpDir = true;
  networking.firewall.allowPing = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "${ssh_key}"
  ];
} 
//
(if has_ip6 then {
  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        { address = "${ip4_address}"; prefixLength = ${ip4_cidr}; }
        { address = "${private_ip4_address}"; prefixLength = ${private_ip4_cidr}; }
      ];
      ipv6.addresses = [
        { address = "${ip6_address}"; prefixLength = ${ip6_cidr}; }
      ];
      ipv4.routes = [{ address = "${ip4_gateway}"; prefixLength = 32; }];
      ipv6.routes = [{ address = "${ip6_gateway}"; prefixLength = 128; }];
   };
 };
} else {
  networking.interfaces = {
    eth0 = {
      ipv4.addresses = [
        { address = "${ip4_address}"; prefixLength = ${ip4_cidr}; }
        { address = "${private_ip4_address}"; prefixLength = ${private_ip4_cidr}; }
      ];
     ipv4.routes = [{ address = "${ip4_gateway}"; prefixLength = 32; }];
    };
  };
})
