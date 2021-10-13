{ stdenv, lib, fetchurl }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "istio";
  istio-install-name = "istio-${version}";

  x86_64-darwin-version = "1.10.5";
  x86_64-darwin-sha256 =
    "d52dd7703097dc90144c3700ab86fa319aa5d9c3830754dda37fe47bf4e79b3f";

  x86_64-linux-version = "1.10.5";
  x86_64-linux-sha256 =
    "538540da396cb226877875b6e50448315dd8721d18782e3762d62299cf576dd8";

  version = {
    x86_64-darwin = x86_64-darwin-version;
    x86_64-linux = x86_64-linux-version;
  }.${system} or throwSystem;

  src =
    let base = "https://github.com/istio/istio/releases/download/${version}";

    in
      {
        x86_64-darwin = fetchurl {
          url = "${base}/istio-${version}-osx.tar.gz";
          sha256 = x86_64-darwin-sha256;
        };
        x86_64-linux = fetchurl {
          url = "${base}/istio-${version}-linux-amd64.tar.gz";
          sha256 = x86_64-linux-sha256;
        };
      }.${system} or throwSystem;

  meta = with lib; {
    description = "Istio Service Mesh";
    homepage = "https://github.com/istio/istio";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-darwin" "x86_64-linux" ];
  };

  istioInstall = stdenv.mkDerivation rec {
    inherit pname version src meta;
    dontBuild = true;
    dontPatchELF = true;

    phases = " unpackPhase installPhase fixupPhase";

    unpackPhase = ''
      runHook preUnpack
      mkdir ${pname}
      tar -C ${pname} -xzf $src
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/${istio-install-name}
      mv ${pname}/${istio-install-name}/ $out
      ln -s $out/${istio-install-name} $out/${pname}
      runHook postInstall
    '';

    fixupPhase = ''
      mkdir -p $out/nix-support
      cat <<EOF > $out/nix-support/setup-hook
      if [ -z "\''${ISTIO_HOME-}" ]; then export ISTIO_HOME=$out/${pname}; fi
      EOF
    '';
  };

in
istioInstall
