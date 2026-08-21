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

  networking = {
    hostName = "stiltzkin";
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
      env = "staging";
      dogstatsd_port = 8125;
    };
  };

  age.secrets.datadog-api-key = {
    file = ../../../secrets/hosts/datadog-key-stiltzkin.age;
    owner = "datadog";
  };

  seabird.caddy.enable = true;
  seabird.caddy.package = pkgs.unstable.caddy;

  seabird.services = {
    seabird-core = {
      enable = true;
      package = pkgs.seabird-staging.seabird-core;

      hosts = [
        "api.staging.seabird.chat"
      ];
    };

    # Backends

    seabird-discord-backend = {
      enable = true;
      package = pkgs.seabird-staging.seabird-discord-backend;
      secretFile = ../../../secrets/staging/seabird-discord-backend.age;
    };

    # Named for the network it connects to, the way prod's instance is named
    # for whyte. That network is the Ergo instance on monty, so this backend
    # reaches no real users and can be restarted freely.
    seabird-irc-backend.instances.monty = {
      enable = true;
      package = pkgs.seabird-staging.seabird-irc-backend;
      secretFile = ../../../secrets/staging/seabird-irc-backend-monty.age;
      channels = [
        "#general"
        "#botspam"
      ];
    };

    # Plugins

    # No plugin list, matching prod: staging runs the same set, so a command
    # that works here is a command that works there. forecast is the only one
    # needing third-party credentials, and staging has its own.
    seabird-plugin-bundle = {
      enable = true;
      package = pkgs.seabird-staging.seabird-plugin-bundle;
      secretFile = ../../../secrets/staging/seabird-plugin-bundle.age;
    };

    seabird-datadog-plugin = {
      enable = true;
      package = pkgs.seabird-staging.seabird-datadog-plugin;
      secretFile = ../../../secrets/staging/seabird-datadog-plugin.age;
    };

    # The pair the private IRC network was built for. Both backends default
    # their id to "seabird", the same as prod, which is unambiguous because each
    # environment has its own core. The Discord ids are staging's own guild.
    seabird-proxy-plugin = {
      enable = true;
      package = pkgs.seabird-staging.seabird-proxy-plugin;
      secretFile = ../../../secrets/staging/seabird-proxy-plugin.age;

      channelGroups = [
        [
          "irc://seabird/%23general"
          "discord://seabird/969285588383592471"
        ]
        [
          "irc://seabird/%23botspam"
          "discord://seabird/1538982707730718830"
        ]
      ];
    };

    seabird-url-plugin = {
      enable = true;
      package = pkgs.seabird-staging.seabird-url-plugin;
      secretFile = ../../../secrets/staging/seabird-url-plugin.age;
    };
  };

  # Builds the staging packages into this guest's store ahead of needing them,
  # so the deploy that enables the services only has to activate. Costs one long
  # deploy now, since --build-on remote means the guest builds them itself.
  system.extraDependencies = [ self.packages.x86_64-linux.all-staging ];

  system.stateVersion = "26.05";
}
