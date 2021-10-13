{ stdenv, lib, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "civo";

  x86_64-darwin-version = "0.7.33";
  x86_64-darwin-sha256 =
    "62370a7a6c77c173f0afec41dc69e622d75c33dc62079dea7e98c6613d7a3cf3";

  x86_64-linux-version = "0.7.33";
  x86_64-linux-sha256 =
    "0c23753347a7e8cc7fe5371a70294b4fbc35a4d4bc9afc93e0789b98076de08d";

  version = {
    x86_64-darwin = x86_64-darwin-version;
    x86_64-linux = x86_64-linux-version;
  }.${system} or throwSystem;

  src =
    let base = "https://github.com/civo/cli/releases/download/v${version}";

    in
      {
        x86_64-darwin = fetchurl {
          url = "${base}/civo-${version}-darwin-amd64.tar.gz";
          sha256 = x86_64-darwin-sha256;
        };
        x86_64-linux = fetchurl {
          url = "${base}/civo-${version}-linux-amd64.tar.gz";
          sha256 = x86_64-linux-sha256;
        };
      }.${system} or throwSystem;

  meta = with lib; {
    description = "Install an civo cli";
    homepage = "https://github.com/civo";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-darwin" "x86_64-linux" ];
  };

  civoInstall = stdenv.mkDerivation rec {
    inherit pname version src meta;
    dontBuild = true;
    dontPatchELF = true;

    phases = " unpackPhase installPhase ";

    unpackPhase = ''
      runHook preUnpack
      mkdir ${pname}
      tar -C ${pname} -xzf $src
    '';

    installPhase = ''
      runHook preInstall

      install -D ${pname}/civo $out/bin/civo

      chmod +x $out/bin/civo

      # completions
      mkdir -p $out/share/bash-completion/completions/
      $out/bin/civo completion bash > $out/share/bash-completion/completions/civo
      #mkdir -p $out/share/zsh/site-functions
      #$out/bin/civo completion zsh > $out/share/zsh/site-functions/_civo

      runHook postInstall
    '';
  };

in
civoInstall
