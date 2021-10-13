{ pkgs, stdenv, lib, fetchFromGitHub, ... }:
let
  name = "kubectl-aliases";

  src = fetchFromGitHub {
    name = "kubectl-aliases";
    owner = "ahmetb";
    repo = "kubectl-aliases";
    rev = "master";
    sha256 = "kwjiCVhkaYVEk5PWdrY5zBzISVvRIFjIWPFNTaa8wl4=";
  };

  meta = with lib; {
    description = "Configure kubectl aliases";
    homepage = "https://github.com/ahmetb/kubectl-aliases";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-darwin" "x86_64-linux" ];
  };

  configureKubectlAliases = stdenv.mkDerivation rec {

    inherit name src meta;

    phases = " installPhase fixupPhase";

    dontUnpack = true;
    dontBuild = true;
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      "${pkgs.python38}/bin/python" $src/generate_aliases.py > kubectl_aliases
      mv kubectl_aliases $out/kubectl_aliases
      runHook postInstall
    '';

  };

in
configureKubectlAliases
