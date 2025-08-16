{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "vivi";
    domain = "elwert.dev";
  };

  seabird.services = {
    seabird-core.enable = true;

    seabird-proxy-plugin = {
      enable = true;

      channelGroups = [
        [
          {
            id = "irc://seabird/%23minecraft";
            name = "IRC";
            format = "irc";
          }
          {
            id = "discord://seabird/854033690669744148";
            name = "Discord";
            format = "discord";
          }
          {
            id = "minecraft://minecraft/minecraft";
            name = "Minecraft";
            format = "minecraft";
          }
        ]
      ];
    };

    seabird-irc-backend.whyte = {
      enable = false;
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

    seabird-plugin-bundle.enable = false;
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
