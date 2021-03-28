{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    smunix-monoid-extras.url = "github:smunix/monoid-extras/fix.diagrams";
  }; 
  outputs = { self, nixpkgs, flake-utils, smunix-monoid-extras, ... }:
    with flake-utils.lib;
    with nixpkgs.lib;
    eachSystem [ "x86_64-darwin" "x86_64-linux" ] (system:
      let version = "${substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
          overlay = self: super:
            with self;
            with haskell.lib;
            with haskellPackages;
            {
              diagrams-core = rec {
                package = overrideCabal (callCabal2nix "diagrams-core" ./. {}) (o: { version = "${o.version}-${version}"; });
              };
            };
          overlays = [ overlay ];
      in
        with (import nixpkgs { inherit system overlays; });
        rec {
          packages = flattenTree (recurseIntoAttrs { diagrams-core = diagrams-core.package; });
          defaultPackage = packages.diagrams-core;
        });
}
