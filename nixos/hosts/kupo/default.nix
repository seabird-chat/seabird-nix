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

    # One instance per Archipelago room. The server address lives in the
    # secret file along with the token and room password.
    seabird-archipelago-backend.instances.nickdavies = {
      enable = false;
      secretFile = ../../../secrets/prod/seabird-archipelago-backend-nickdavies.age;
      slot = "BelakRac2";
      itemFilter = [ "progression" ];
    };

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
        "#books"
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

    seabird-nwwsio-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-nwwsio-plugin.age;
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
          # Techies Be Craftin' #minecraft
          {
            type = "discord";
            id = "sbc_5apc0ymd86xkc";
          }
        ]
        [
          # #main
          {
            type = "irc";
            id = "sbc_r7mn7h863jvb8";
          }
          # #main
          {
            type = "discord";
            id = "sbc_jhh1jvfqh8ntg";
          }
        ]
        [
          # #books
          {
            type = "irc";
            id = "sbc_7w18vpjg4gm9m";
          }
          # #books
          {
            type = "discord";
            id = "sbc_cc9hej3e2999a";
          }
        ]
        [
          # #parenting
          {
            type = "irc";
            id = "sbc_7m5ph6efbv8jj";
          }
          # #parenting
          {
            type = "discord";
            id = "sbc_wb0zexa4vz9kp";
          }
        ]
        [
          # #osrs
          {
            type = "irc";
            id = "sbc_k6jgbz6qetrk4";
          }
          # #osrs
          {
            type = "discord";
            id = "sbc_khnwzrdd71ana";
          }
        ]
        [
          # #rocketcraft
          {
            type = "irc";
            id = "sbc_cwh0ymeyjmawm";
          }
          # #rocketcraft
          {
            type = "discord";
            id = "sbc_2h5j9wxz36d60";
          }
        ]
        [
          # #encoded-test
          {
            type = "irc";
            id = "sbc_4zaka0td6y8bm";
          }
          # #encoded-test
          {
            type = "discord";
            id = "sbc_89n3r40dqm4k2";
          }
        ]
        [
          # #encoded
          {
            type = "irc";
            id = "sbc_bw1v6fekp1b1w";
          }
          # #encoded
          {
            type = "discord";
            id = "sbc_5y05dm4kzn6va";
          }
        ]
        [
          # #hamateurs
          {
            type = "irc";
            id = "sbc_98vjhhvtmjx98";
          }
          # #hamateurs
          {
            type = "discord";
            id = "sbc_jhgd9n78z1m1a";
          }
        ]
        [
          # #homelab
          {
            type = "irc";
            id = "sbc_64vfxxkkgnsgt";
          }
          # #homelab
          {
            type = "discord";
            id = "sbc_kb8avsh2r0hvr";
          }
        ]
        [
          # #mtg
          {
            type = "irc";
            id = "sbc_jszb1hm8hhqxe";
          }
          # #mtg
          {
            type = "discord";
            id = "sbc_z2han3nb3hscy";
          }
        ]
        [
          # #rust
          {
            type = "irc";
            id = "sbc_y83t6ck2a1adw";
          }
          # #rust
          {
            type = "discord";
            id = "sbc_gtg03pjk9nam2";
          }
        ]
        [
          # #politics
          {
            type = "irc";
            id = "sbc_fvmqayxj0ntc8";
          }
          # #strongly-held-opinions
          {
            type = "discord";
            id = "sbc_tnqnyz4899wep";
          }
        ]
        [
          # #music
          {
            type = "irc";
            id = "sbc_vxarfjk6gb07e";
          }
          # #music
          {
            type = "discord";
            id = "sbc_qp2c2d0c9kvtc";
          }
        ]
        [
          # #weight-loss-challenge
          {
            type = "irc";
            id = "sbc_n0az4m4sbrz6p";
          }
          # #weight-loss-challenge
          {
            type = "discord";
            id = "sbc_j309f8vbfsw68";
          }
        ]
        [
          # #adventofcode
          {
            type = "irc";
            id = "sbc_jz2p3ab499xpt";
          }
          # #advent-of-code
          {
            type = "discord";
            id = "sbc_50x22m6zpqhca";
          }
        ]
        [
          # #ai
          {
            type = "irc";
            id = "sbc_px826hya0sxbw";
          }
          # #ai
          {
            type = "discord";
            id = "sbc_5htwjzs3tawga";
          }
        ]
        [
          # #botspam
          {
            type = "irc";
            id = "sbc_nejm6z4q8frha";
          }
          # #botspam
          {
            type = "discord";
            id = "sbc_a250a54b663nm";
          }
        ]
        [
          # #stonks
          {
            type = "irc";
            id = "sbc_xfpg7cszyeerj";
          }
          # #stonks
          {
            type = "discord";
            id = "sbc_d2gfg6mrq1v9m";
          }
        ]

        # cozy-calzones
        [
          # cozy-calzones
          {
            type = "minecraft";
            id = "sbc_hew5d2a6gb0zc";
          }
          # Calzone #minecraft
          {
            type = "discord";
            id = "sbc_yrndjamz1xqxe";
          }
        ]
      ];
    };

    seabird-rcon-plugin = {
      enable = true;
      secretFile = ../../../secrets/prod/seabird-rcon-plugin.age;

      servers.cozy-calzones = {
        address = "freya.elwert.dev:25575";
        passwordSecretFile = ../../../secrets/prod/seabird-rcon-plugin-cozy-calzones.age;
        mapUrl = "https://mc-calzone.elwert.cloud";
        channels = [ "sbc_yrndjamz1xqxe" ]; # Calzone #minecraft
        operatorChannels = [ "sbc_yrndjamz1xqxe" ]; # Calzone #minecraft
        admins = [ "sbu_mmzmawqd97qp6" ]; # discord user belak
      };
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

      target = "sbc_89n3r40dqm4k2"; # #encoded-test
    };
  };

  # Builds the release packages into this guest's store ahead of needing them,
  # so the deploy that enables the services only has to activate. Costs one long
  # deploy now, since --build-on remote means the guest builds them itself.
  system.extraDependencies = [ self.packages.x86_64-linux.all-prod ];

  system.stateVersion = "26.05";
}
