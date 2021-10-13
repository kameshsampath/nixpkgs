{ config, lib, pkgs, ... }:

with lib;
let cfg = config.programs.istio;
in
{
  options = {

    programs.istio = {

      enable = mkEnableOption "istio" // {
        description = ''
          Install and setup the Istio development kit.
          <note>
          <para>This adds ISTIO_HOME to the global environment, by sourcing the
            istio's setup-hook on shell init. It is equivalent to starting a shell
            through 'nix-shell -p istio', or roughly the following system-wide
            configuration:
          </para>
          <programlisting>
            environment.variables.ISTIO_HOME = ''${pkgs.kameshsampath.istio.home}/istio;
            environment.systemPackages = [ pkgs.kameshsampath.istio ];
          </programlisting>
          </note>
        '';
      };

      package = mkOption {
        default = pkgs.kameshsampath.istio;
        description = "istio package to be used";
        type = types.package;
      };

    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ cfg.package ];

    programs.zsh = {
      initExtra = ''
        test -e ${cfg.package}/nix-support/setup-hook && source ${cfg.package}/nix-support/setup-hook
        path+="$ISTIO_HOME/bin"
      '';
    };

    programs.bash = {
      initExtra = ''
        test -e ${cfg.package}/nix-support/setup-hook && source ${cfg.package}/nix-support/setup-hook
        path+="$ISTIO_HOME/bin"
      '';
    };
  };
}
