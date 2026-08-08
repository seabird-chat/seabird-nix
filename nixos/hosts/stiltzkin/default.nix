{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "stiltzkin";
    domain = "infra.seabird.chat";
  };

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
    file = ../../../secrets/datadog-key-stiltzkin.age;
    owner = "datadog";
  };

  seabird.atticCache.enable = true;

  #seabird.haproxy.enable = true;
  #seabird.haproxy.package = pkgs.unstable.haproxy;

  seabird.caddy.enable = false;
  seabird.caddy.package = pkgs.unstable.caddy;

  seabird.services = {
    seabird-core = {
      enable = true;

      hosts = [
        "api.seabird.chat"
      ];
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
  system.stateVersion = "26.05"; # Did you read the comment?
}
