{ stdenv, lib, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "glooctl";

  x86_64-darwin-version = "1.9.0";
  x86_64-darwin-sha256 = "5a04c211cc873dee9492d1b570c15091d81638e548744ba1370e9688ae2544ac";

  x86_64-linux-version = "1.9.0";
  x86_64-linux-sha256 = "30bc112f8796aaa84bb5c33c49d0c18a45f468db9ad95cfe4075028c24e51508";

  version = {
    x86_64-darwin = x86_64-darwin-version;
    x86_64-linux = x86_64-linux-version;
  }.${system} or throwSystem;

  src =
    let base = "https://github.com/solo-io/gloo/releases/download/v${version}";

    in
      {
        x86_64-darwin = fetchurl {
          url = "${base}/glooctl-darwin-amd64";
          sha256 = x86_64-darwin-sha256;
        };
        x86_64-linux = fetchurl {
          url = "${base}/glooctl-linux-amd64";
          sha256 = x86_64-linux-sha256;
        };
      }.${system} or throwSystem;

  meta = with lib; {
    description = "Install an glooctl";
    homepage = "https://github.com/solo-io/gloo";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-darwin" "x86_64-linux" ];
  };

  glooctlInstall = stdenv.mkDerivation rec {
    inherit pname version src meta;
    dontUnpack = true;
    dontBuild = true;
    dontPatchELF = true;
    installPhase = ''
      runHook preInstall
      # mkdir -p $out/bin
      
      install -D $src $out/bin/glooctl

      chmod +x $out/bin/glooctl

      runHook postInstall
    '';
  };

in
glooctlInstall
