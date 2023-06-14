{ lib ? (import <nixpkgs> {}).lib, modules ? [] }:
let
  lib' = lib.extend(final: prev: {
    types = prev.types // { fluent = import ../../fluent.nix { inherit lib; }; };
  });
in
{
  inherit (lib'.evalModules {
    inherit modules;
    specialArgs.modulesPath = ./.;
  }) config options;
}
