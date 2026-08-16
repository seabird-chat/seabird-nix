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
  # Readable by every host.
  "secrets/common/belak-password.age".publicKeys = users ++ systems;
  "secrets/common/ghavil-password.age".publicKeys = users ++ systems;
  "secrets/common/nix-netrc.age".publicKeys = users ++ systems;

  # One per host, so a compromised guest cannot report as another.
  "secrets/hosts/datadog-key-eiko.age".publicKeys = users ++ [ system-eiko ];
  "secrets/hosts/datadog-key-kupo.age".publicKeys = users ++ [ system-kupo ];
  "secrets/hosts/datadog-key-stiltzkin.age".publicKeys = users ++ [ system-stiltzkin ];

  "secrets/prod/seabird-adventofcode-plugin.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-datadog-plugin.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-discord-backend.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-github-plugin.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-irc-backend-whyte.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-plugin-bundle.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-proxy-plugin.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-stock-plugin.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-url-plugin.age".publicKeys = users ++ env-prod;
  "secrets/prod/seabird-webhook-receiver.age".publicKeys = users ++ env-prod;

  "secrets/staging/seabird-discord-backend.age".publicKeys = users ++ env-staging;

  # TODO: move common API keys into separate files
}
