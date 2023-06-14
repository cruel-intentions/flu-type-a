{
  description = "Incubation of fluent type for nix modules";
  inputs.nixpkgs.url  = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs }: {
    overlays.lib = final: prev: {
      types = prev.types // rec {
        flu    = import ./lib/fluent.nix;
        fluent = flu { lib = final.lib; };
      };
    };
    overlays.default = final: prev: { lib = self.lib; };
    lib = nixpkgs.lib.extend (self.overlay.lib);
    packages.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; stdenvNoCC.mkDerivation {
      name        = "flu-type-a-test";
      src         = ./.;
      buildInputs = [ bash nix ];
      buildPhase  = ''
        mkdir -p $out/bin
        cp -r . $out
        printf "#!/usr/bin/env bash\n$out/lib/tests/fluent.sh" \
          > $out/bin/flu-type-a-test
        chmod +x $out/bin/flu-type-a-test
      '';
    };
  };
}
