{ config, lib, pkgs, ... }: {

  # Set-up cache
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
