{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-core;

  bindHost = "0.0.0.0:8080";
in
{
  options = {
    seabird.services.seabird-core = {
      enable = lib.mkEnableOption "seabird-core";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-core;
      };
      hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
      databaseUrl = lib.mkOption {
        type = lib.types.str;
        default = "file:/var/lib/seabird-core/seabird-go.db";
        description = "SQLite database holding the auth tokens, as a filename or file: URI.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Restarting core drops every other seabird service, all of which exit when
    # the connection goes. At the default 100ms restart they spend systemd's
    # five-starts-in-ten-seconds allowance before core is listening again, end
    # up in failed, and deploy-rs rolls the deploy back.
    #
    # Every service that connects to core needs to set RestartSec = 5 and
    # startLimitIntervalSec = 0, and orders itself after seabird-core.service.
    systemd.services.seabird-core = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        SEABIRD_DATABASE_URL = cfg.databaseUrl;
        SEABIRD_BIND_HOST = bindHost;
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${cfg.package}/bin/seabird-core serve";
        StateDirectory = "seabird-core";
      };
    };

    seabird.caddy.virtualHosts.seabird-core = {
      inherit (cfg) hosts;

      backend = "h2c://localhost:8080"; # TODO: this is hard coded
    };
  };
}
