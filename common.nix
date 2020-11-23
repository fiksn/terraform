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

  swapDevices = [{ device = "/swapfile"; size = 1024; }];
  environment.systemPackages = with pkgs; [ tcpdump nmap git go curl bash bc coreutils dos2unix htop jq mosh netcat pssh pv pwgen screen strace tmux tshark unzip vim wget telnet rsync ncdu ];
}
