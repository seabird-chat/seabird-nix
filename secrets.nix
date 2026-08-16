let
  user-belak-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUSx9TTTHUq4GOkeBU4Ga03QombEBiZLqqa8KIqnnUy";
  user-belak-melinoe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzuXboQDv2VCig0+A780O0+sKs1euw+3OafnRA6z14P";
  user-belak-zagreus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNHMEfjGg5ek6OtbFytZ/zCSZosT8aHqHRfnufb3gIi";

  users = [
    user-belak-work
    user-belak-melinoe
    user-belak-zagreus
  ];

  system-eiko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFpH5p7ODkUq0kLqda1/fghcCo+MxvCZLdKOfhZCtK+";
  system-kupo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE679sZWB/+sWPM/W29xxB/NKopAkE13daMDXlRsecEE";
  system-stiltzkin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPY4Di/gKC190MFcJrPtMGgXhP1CeKtLrIQuBopvquG";

  systems = [
    system-eiko
    system-kupo
    system-stiltzkin
  ];

  env-prod = [
    system-kupo
  ];

  env-staging = [
    system-stiltzkin
  ];
in
{
  "secrets/belak-password.age".publicKeys = users ++ systems;
  "secrets/ghavil-password.age".publicKeys = users ++ systems;

  # One per host, so a compromised guest cannot report as another.
  "secrets/datadog-key-eiko.age".publicKeys = users ++ [ system-eiko ];
  "secrets/datadog-key-kupo.age".publicKeys = users ++ [ system-kupo ];
  "secrets/datadog-key-stiltzkin.age".publicKeys = users ++ [ system-stiltzkin ];

  # nix daemon netrc, holding the seabird attic cache pull token
  "secrets/nix-netrc.age".publicKeys = users ++ systems;

  # Backends
  "secrets/seabird-discord-backend.age".publicKeys = users ++ env-prod;
  "secrets/seabird-irc-backend-whyte.age".publicKeys = users ++ env-prod;

  # Plugins
  "secrets/seabird-adventofcode-plugin.age".publicKeys = users ++ env-prod;
  "secrets/seabird-datadog-plugin.age".publicKeys = users ++ env-prod;
  "secrets/seabird-github-plugin.age".publicKeys = users ++ env-prod;
  "secrets/seabird-plugin-bundle.age".publicKeys = users ++ env-prod;
  "secrets/seabird-proxy-plugin.age".publicKeys = users ++ env-prod;
  "secrets/seabird-stock-plugin.age".publicKeys = users ++ env-prod;
  "secrets/seabird-url-plugin.age".publicKeys = users ++ env-prod;

  # Other
  "secrets/seabird-webhook-receiver.age".publicKeys = users ++ env-prod;

  # TODO: move common API keys into separate files
}
