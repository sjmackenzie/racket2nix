let
  bootPkgs = import <nixpkgs> { };
  remotePkgs = bootPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "a66ce38acea505c4b3bfac9806669d2ad8b34efa";
    sha256 = "1jrz6lkhx64mvm0h4gky9b6iaazivq69smppkx33hmrm4553dx5h";
  };
in
{ pkgs ? import remotePkgs { }
, stdenvNoCC ? pkgs.stdenvNoCC
, racket ? pkgs.callPackage ./racket-minimal.nix {}
, racket2nix ? pkgs.callPackage ./. { inherit racket; }
, racket2nix-stage0 ? pkgs.callPackage ./stage0.nix { inherit racket; }
, colordiff ? pkgs.colordiff
, racket-catalog ? pkgs.callPackage ./catalog.nix { inherit racket; }
}:

let attrs = rec {
  inherit pkgs;
  inherit racket2nix;
  inherit racket2nix-stage0;
  racket-doc-nix = { extraArgs ? ""} : stdenvNoCC.mkDerivation {
    name = "racket-doc.nix";
    buildInputs = [ racket2nix ];
    phases = "installPhase";
    installPhase = ''
      racket2nix ${extraArgs} --catalog ${racket-catalog} racket-doc > $out
    '';
  };
  racket-doc = pkgs.callPackage (racket-doc-nix {}) { inherit racket; };
  racket-doc-flat-nix = racket-doc-nix { extraArgs = "--flat"; };
  racket-doc-flat = pkgs.callPackage racket-doc-flat-nix { inherit racket; };
};
in
attrs.racket-doc // attrs
