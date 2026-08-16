{
  self,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  # Seabird production. No agenix secrets yet: the host key is generated at
  # first boot, then added to secrets.nix and rekeyed.
  networking = {
    hostName = "kupo";
    domain = "infra.seabird.chat";

    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "ipv4";

    # The domain fixes the MAC, so identifying by it keeps the DHCP reservation
    # valid across rebuilds and reinstalls.
    dhcpV4Config.ClientIdentifier = "mac";
  };

  seabird.atticCache.enable = true;

  services.datadog-agent = {
    enable = true;
    site = "datadoghq.com";
    apiKeyFile = config.age.secrets.datadog-api-key.path;
    extraConfig = {
      env = "prod";
      dogstatsd_port = 8125;
    };
  };

  age.secrets.datadog-api-key = {
    file = ../../../secrets/hosts/datadog-key-kupo.age;
    owner = "datadog";
  };

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

    seabird-discord-backend = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-discord-backend.age;
    };

    seabird-irc-backend.instances.whyte = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-irc-backend-whyte.age;
      channels = [
        "#adventofcode"
        "#ai"
        "#botspam"
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

    seabird-adventofcode-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-adventofcode-plugin.age;
    };

    seabird-datadog-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-datadog-plugin.age;
    };

    seabird-github-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-github-plugin.age;

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

    seabird-plugin-bundle = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-plugin-bundle.age;
    };

    seabird-proxy-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-proxy-plugin.age;

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
        [
          "irc://seabird/%23weight%2Dloss%2Dchallenge"
          "discord://seabird/1453170802404102174"
        ]
        [
          "irc://seabird/%23adventofcode"
          "discord://seabird/779077086244503623"
        ]
        [
          "irc://seabird/%23ai"
          "discord://seabird/1493422104593301524"
        ]
        [
          "irc://seabird/%23botspam"
          "discord://seabird/1503211422522413297"
        ]
        [
          "irc://seabird/%23stonks"
          "discord://seabird/1519542812293730314"
        ]
      ];
    };

    seabird-stock-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-stock-plugin.age;
    };

    seabird-url-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-url-plugin.age;
    };

    # Other

    seabird-webhook-receiver = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-webhook-receiver.age;

      hosts = [
        "webhooks.seabird.chat"
      ];

      target = "discord://seabird/721047808077070446";
    };
  };

  environment.systemPackages = [
    pkgs.sqlite
  ];

  # Builds the release packages into this guest's store ahead of needing them,
  # so the deploy that enables the services only has to activate. Costs one long
  # deploy now, since --build-on remote means the guest builds them itself.
  system.extraDependencies = [ self.packages.x86_64-linux.all-prod ];

  system.stateVersion = "26.05";
}
