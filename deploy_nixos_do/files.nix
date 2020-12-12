{ pkgs ? import <nixpkgs> {}, file ? ./configuration.temp, ... }:
let
  lib = pkgs.lib;
  
  resolveOne = file: let p = pkgs.callPackage file {}; in lib.filter (x: !lib.hasPrefix "/nix" (builtins.toPath x)) (if lib.hasAttr "imports" p then p.imports else []);
  oneStep = result: lib.unique (lib.foldl' (x: y:  x ++ resolveOne y) result result);
  resolve = input: let resolveRec = x: let y = oneStep x; in if lib.length x == lib.length y then y else resolveRec y; in resolveRec [ input ];

  getPrefix = main: let file = builtins.toPath main; name = builtins.baseNameOf file; root = lib.replaceStrings [ "/${name}" ] [ ""] file; in root;
  getRelativePaths = main: let prefix = getPrefix main; in map (x: lib.replaceStrings [ prefix ] [ "." ] (builtins.toPath x)) (resolve main);
  getRelativePathsStr = main: builtins.concatStringsSep "\n" (getRelativePaths main);
in
pkgs.mkShell {
  shellHook = ''
    echo "${getRelativePathsStr file}"
  '';
}
