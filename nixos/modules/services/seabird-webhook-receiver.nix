{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-webhook-receiver;
in
{
  options = {
    seabird.services.seabird-webhook-receiver = {
      enable = lib.mkEnableOption "seabird-core";

      hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      target = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-webhook-receiver = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        SEABIRD_HOST = "http://localhost:8080";
        SEABIRD_BIND_HOST = "127.0.0.1:8080";
        SEABIRD_CHANNEL = cfg.target;
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-webhook-receiver}/bin/seabird-webhook-receiver";
        EnvironmentFile = [
          config.age.secrets."seabird-webhook-receiver".path
        ];
      };
    };

    age.secrets."seabird-webhook-receiver".file = ../../../secrets + "/seabird-webhook-receiver.age";

    seabird.haproxy.backends.seabird-webhook-receiver = {
      inherit (cfg) hosts;

      servers.seabird-webhook-receiver = "localhost:3000"; # TODO: this is hard coded
    };
  };
}
