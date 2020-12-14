{ pkgs ? import <nixpkgs> {}, file ? ./configuration.temp, ... }:
let
  lib = pkgs.lib;
  
  # Handle the case when file is not a function
  openFile = file: let p = import file; in if lib.isAttrs p then (x: p) else p;

  resolveOne = file: let p = pkgs.callPackage (openFile file) {}; in lib.filter (x: !lib.hasPrefix "/nix" (builtins.toPath x)) (if lib.hasAttr "imports" p then p.imports else []);
  tryResolveOne = file: let attempt = builtins.tryEval (resolveOne file); in if !attempt.success then [] else attempt.value;
  #tryResolveOne = file: let dummy = builtins.trace "Filename is ${file}" file; attempt = builtins.tryEval (resolveOne dummy); in if !attempt.success then [] else attempt.value;

  oneStep = result: lib.unique (lib.foldl' (x: y:  x ++ tryResolveOne y) result result);
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
