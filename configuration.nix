{ config, lib, pkgs, ... }: {
  imports = [ <nixpkgs/nixos/modules/virtualisation/digital-ocean-image.nix> ./burek.nix ];
  boot.loader.grub.device = "/dev/vda";

  #fileSystems."/" = { device = "/dev/vda1"; fsType = "ext4"; };

  # NETWORKING

  boot.cleanTmpDir = true;
  networking.firewall.allowPing = true;
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "${key}"
  ];

  nix = {
    binaryCaches = [
      "https://fiksn.cachix.org"
      "https://cache.nixos.org/"
    ];
    binaryCachePublicKeys = [
      "fiksn.cachix.org-1:BCEC7wp4PVp/atgIlbBSpNWOuPx7Zq4+cxwRqaMrSOc="
    ];
  };
  
}
