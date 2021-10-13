{ stdenv, lib, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "meshctl";

  x86_64-darwin-version = "1.1.2";
  x86_64-darwin-sha256 = "ae771082767f27c03ef65858860c014cd1b17c865f27b14850c6f307cdcd4946";

  x86_64-linux-version = "1.1.2";
  x86_64-linux-sha256 = "57333bb9b9f177364ddf8dca0188df4f5f1f980b723fab0b6b3c42a198b4b671";

  version = {
    x86_64-darwin = x86_64-darwin-version;
    x86_64-linux = x86_64-linux-version;
  }.${system} or throwSystem;

  # https://github.com/solo-io/gloo-mesh/releases/download/v1.1.2/meshctl-darwin-amd64

  src =
    let base = "https://github.com/solo-io/gloo-mesh/releases/download/v${version}";

    in
      {
        x86_64-darwin = fetchurl {
          url = "${base}/meshctl-darwin-amd64";
          sha256 = x86_64-darwin-sha256;
        };
        x86_64-linux = fetchurl {
          url = "${base}/meshctl-linux-amd64";
          sha256 = x86_64-linux-sha256;
        };
      }.${system} or throwSystem;

  meta = with lib; {
    description = "Install an meshctl";
    homepage = "https://github.com/solo-io/gloo-mesh";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-darwin" "x86_64-linux" ];
  };

  meshctlInstall = stdenv.mkDerivation rec {
    inherit pname version src meta;
    dontUnpack = true;
    dontBuild = true;
    dontPatchELF = true;
    installPhase = ''
      runHook preInstall
      # mkdir -p $out/bin
      
      install -D $src $out/bin/meshctl

      chmod +x $out/bin/meshctl

      runHook postInstall
    '';
  };

in
meshctlInstall
