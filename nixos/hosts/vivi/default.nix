{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "vivi";
    domain = "elwert.dev";
  };

  services.datadog-agent = {
    enable = true;
    site = "datadoghq.com";
    apiKeyFile = config.age.secrets.datadog-api-key.path;
    extraConfig = {
      dogstatsd_port = 8125;
    };
  };

  age.secrets.datadog-api-key = {
    file = ../../../secrets/datadog-key-vivi.age;
    owner = "datadog";
  };

  #seabird.haproxy.enable = true;
  #seabird.haproxy.package = pkgs.unstable.haproxy;

  seabird.caddy.enable = true;
  seabird.caddy.package = pkgs.unstable.caddy;

  seabird.services = {
    seabird-core = {
      enable = true;

      hosts = [
        "api.seabird.chat"
      ];
    };

    # Backends

    seabird-discord-backend.enable = true;

    seabird-irc-backend.whyte = {
      enable = true;
      channels = [
        "#adventofcode"
        "#coffee"
        "#encoded"
        "#encoded-test"
        "#gemini"
        "#hamateurs"
        "#homelab"
        "#mtg"
        "#osrs"
        "#parenting"
        "#politics"
        "#music"
        "#rocketcraft"
        "#rust"
        "#stonks"
        "#weight-loss-challenge"
      ];
    };

    # Plugins

    seabird-adventofcode-plugin.enable = true;

    seabird-datadog-plugin.enable = true;

    seabird-github-plugin = {
      enable = true;

      repos = {
        default = "seabird-chat/seabird-plugin-bundle";
        core = "seabird-chat/seabird-core";
        datadog = "seabird-chat/seabird-datadog-plugin";
        discord = "seabird-chat/seabird-discord-backend";
        irc = "seabird-chat/seabird-irc-backend";
        minecraft = "seabird-chat/seabird-minecraft-backend";
        adventofcode = "seabird-chat/seabird-adventofcode-plugin";
        github = "seabird-chat/seabird-github-plugin";
        proxy = "seabird-chat/seabird-proxy-plugin";
        stock = "seabird-chat/seabird-stock-plugin";
        url = "seabird-chat/seabird-url-plugin";
        webhook = "seabird-chat/seabird-webhook-receiver";
        test = "seabird-chat/integrations-test";
      };
    };

    seabird-plugin-bundle.enable = true;

    seabird-proxy-plugin = {
      enable = true;

      channelGroups = [
        [
          "irc://seabird/%23minecraft"
          "discord://seabird/854033690669744148"
          "minecraft://minecraft/minecraft"
        ]
        [
          "irc://seabird/%23main"
          "discord://seabird/1314229653170290718"
        ]
        [
          "irc://seabird/%23parenting"
          "discord://seabird/1259864065673531565"
        ]
        [
          "irc://seabird/%23osrs"
          "discord://seabird/1308611261449113671"
        ]
        [
          "irc://seabird/%23rocketcraft"
          "discord://seabird/695070284935593998"
        ]
        [
          "irc://seabird/%23encoded%2Dtest"
          "discord://seabird/721047808077070446"
        ]
        [
          "irc://seabird/%23encoded"
          "discord://seabird/708529666251554868"
        ]
        [
          "irc://seabird/%23hamateurs"
          "discord://seabird/1368239310322794567"
        ]
        [
          "irc://seabird/%23homelab"
          "discord://seabird/739188060171927633"
        ]
        [
          "irc://seabird/%23mtg"
          "discord://seabird/759988791510695976"
        ]
        [
          "irc://seabird/%23rust"
          "discord://seabird/779077982916444299"
        ]
        [
          "irc://seabird/%23politics"
          "discord://seabird/773402198222307332"
        ]
        [
          "irc://seabird/%23music"
          "discord://seabird/788837956101865472"
        ]
      ];
    };

    seabird-stock-plugin.enable = true;

    seabird-url-plugin.enable = true;

    # Other

    seabird-webhook-receiver = {
      enable = true;

      hosts = [
        "webhooks.seabird.chat"
        "seabird-webhooks.elwert.cloud"
      ];

      target = "discord://seabird/721047808077070446";
    };
  };

  environment.systemPackages = [
    pkgs.sqlite
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
