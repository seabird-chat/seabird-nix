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
      repos = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-github-plugin = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        SEABIRD_HOST = "http://localhost:8080";
        GITHUB_REPOS = lib.strings.concatStringsSep "," (
          lib.attrsets.mapAttrsToList (name: value: "${name}=${value}") cfg.repos
        );
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-github-plugin}/bin/seabird-github-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-github-plugin".path
        ];
      };
    };

    age.secrets."seabird-github-plugin".file = ../../../secrets + "/seabird-github-plugin.age";
  };
}
