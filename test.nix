{ pkgs ? import <nixpkgs> { }, ... }:
let
  lib = pkgs.lib;
  nixos = import <nixpkgs/nixos> { };
  check = f: msg: assert (lib.assertMsg f "FAIL ${msg}"); "PASS ${msg}";
  words = str: lib.filter (x: x != [ ]) (builtins.split " |\r|\n|\t" str);
  sum = list: builtins.foldl' (x: y: x + y) 0 list;
  normalUsers = builtins.filter (x: x.isNormalUser) (lib.toList (lib.attrValues nixos.config.users.users));
  users = normalUsers ++ (lib.toList nixos.config.users.users.root);
  normalUsernames = map (x: x.name) normalUsers;
  testRun = "Users:\n" 
    + check (builtins.length users > 0) "More than 0 users\n"
  ;
in
pkgs.mkShell {
  shellHook = ''
    echo "${testRun}"

    echo "Tests passed"
    exit 0
  '';
}
