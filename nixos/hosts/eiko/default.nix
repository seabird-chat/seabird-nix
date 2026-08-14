{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "eiko";
    domain = "infra.seabird.chat";

    # systemd-networkd allows for easier bridge configuration, which we need for
    # when we start introducing microvms.
    useNetworkd = true;

    useDHCP = false;
    interfaces.eno1.useDHCP = true;
  };

  services.datadog-agent = {
    enable = true;
    site = "datadoghq.com";
    apiKeyFile = config.age.secrets.datadog-api-key.path;
    extraConfig = {
      env = "production";
      dogstatsd_port = 8125;
    };
  };

  age.secrets.datadog-api-key = {
    file = ../../../secrets/datadog-key-eiko.age;
    owner = "datadog";
  };

  # The MicroVM guests mount this host's /nix/store read-only, so every
  # closure they run has to be here first. Building it into eiko's own system
  # closure warms the store and keeps nix.gc from collecting it between the
  # time a guest is defined and the time its services are enabled. Staging is
  # included so stiltzkin costs nothing extra later.
  system.extraDependencies = lib.attrValues pkgs.seabird ++ lib.attrValues pkgs.seabird-staging;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
