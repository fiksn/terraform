{ pkgs ? import <nixpkgs> {} }:
with pkgs;
{
  shell = mkShell {
    name = "terraform-provisioner";

    buildInputs = [
      terraform
      ipcalc 
      curl 
      jq
    ];
  };
}
