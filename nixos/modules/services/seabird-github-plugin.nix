{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-github-plugin;
in
{
  options = {
    seabird.services.seabird-github-plugin = {
      enable = lib.mkEnableOption "seabird-github-plugin";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-github-plugin;
      };

      secretFile = lib.mkOption {
        type = lib.types.path;
      };
      repos = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-github-plugin = {
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "seabird-core.service"
      ];
      after = [
        "network-online.target"
        "seabird-core.service"
      ];
      startLimitIntervalSec = 0;
      restartTriggers = [ (builtins.hashFile "sha256" cfg.secretFile) ];
      environment = {
        SEABIRD_HOST = "http://localhost:8080";
        GITHUB_REPOS = lib.strings.concatStringsSep "," (
          lib.attrsets.mapAttrsToList (name: value: "${name}=${value}") cfg.repos
        );
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        ExecStart = "${cfg.package}/bin/seabird-github-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-github-plugin".path
        ];
      };
    };

    age.secrets."seabird-github-plugin".file = cfg.secretFile;
  };
}
