{
  self,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Seabird production. No agenix secrets yet: the host key is generated at
  # first boot, then added to secrets.nix and rekeyed.
  networking = {
    hostName = "atla";
    domain = "infra.seabird.chat";
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
    file = ../../../secrets/hosts/datadog-key-atla.age;
    owner = "datadog";
  };

  #seabird.caddy.enable = true;
  #seabird.caddy.package = pkgs.unstable.caddy;

  seabird.services = {
    seabird-core = {
      #enable = true;

      hosts = [
        "api.seabird.chat"
      ];
    };

    # Backends

    seabird-discord-backend = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-discord-backend.age;
    };

    seabird-irc-backend.instances.whyte = {
      #enable = true;
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
        "#monitoring"
        "#mtg"
        "#osrs"
        "#parenting"
        "#politics"
        "#music"
        "#rocketcraft"
        "#rust"
        "#stonks"
        "#techsmix"
        "#weight-loss-challenge"
      ];
    };

    # Plugins

    seabird-adventofcode-plugin = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-adventofcode-plugin.age;
    };

    seabird-datadog-plugin = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-datadog-plugin.age;
    };

    seabird-github-plugin = {
      #enable = true;
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

    seabird-nwwsio-plugin = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-nwwsio-plugin.age;
    };

    seabird-plugin-bundle = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-plugin-bundle.age;
    };

    seabird-stock-plugin = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-stock-plugin.age;
    };

    seabird-url-plugin = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-url-plugin.age;
    };

    # Other

    seabird-webhook-receiver = {
      #enable = true;
      secretFile = ../../../secrets/prod/seabird-webhook-receiver.age;

      hosts = [
        "webhooks.seabird.chat"
      ];

      target = "discord://seabird/721047808077070446";
    };
  };

  # Builds the release packages into this guest's store ahead of needing them,
  # so the deploy that enables the services only has to activate. Costs one long
  # deploy now, since --build-on remote means the guest builds them itself.
  #system.extraDependencies = [ self.packages.x86_64-linux.all-prod ];

  system.stateVersion = "26.05";
}
