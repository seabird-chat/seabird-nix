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
        DATABASE_URL = "sqlite:///var/lib/seabird-core/seabird-core.db";

        # The Rust implementation reads SEABIRD_BIND_HOST and the Go one reads
        # BIND_HOST. Both are set so either package can be deployed here without
        # silently falling back to a different port. Drop SEABIRD_BIND_HOST once
        # the Go implementation is the only one left.
        SEABIRD_BIND_HOST = bindHost;
        BIND_HOST = bindHost;
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${cfg.package}/bin/seabird-core";
        StateDirectory = "seabird-core";
      };
    };

    seabird.caddy.virtualHosts.seabird-core = {
      inherit (cfg) hosts;

      backend = "h2c://localhost:8080"; # TODO: this is hard coded
    };
  };
}
