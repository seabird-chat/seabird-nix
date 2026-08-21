let
  keys = import ./secrets/keys.nix;

  inherit (keys) users systems;

  env-prod = [
    keys.system-kupo
  ];

  env-staging = [
    keys.system-stiltzkin
  ];
in
{
  # Readable by every host.
  "secrets/common/belak-password.age".publicKeys = users ++ systems;
  "secrets/common/ghavil-password.age".publicKeys = users ++ systems;
  "secrets/common/nix-netrc.age".publicKeys = users ++ systems;

  # One per host, so a compromised guest cannot report as another.
  "secrets/hosts/datadog-key-eiko.age".publicKeys = users ++ [ keys.system-eiko ];
  "secrets/hosts/datadog-key-kupo.age".publicKeys = users ++ [ keys.system-kupo ];
  "secrets/hosts/datadog-key-monty.age".publicKeys = users ++ [ keys.system-monty ];
  "secrets/hosts/datadog-key-stiltzkin.age".publicKeys = users ++ [ keys.system-stiltzkin ];

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
  "secrets/staging/seabird-irc-backend-monty.age".publicKeys = users ++ env-staging;
  "secrets/staging/seabird-datadog-plugin.age".publicKeys = users ++ env-staging;
  "secrets/staging/seabird-plugin-bundle.age".publicKeys = users ++ env-staging;
  "secrets/staging/seabird-proxy-plugin.age".publicKeys = users ++ env-staging;
  "secrets/staging/seabird-url-plugin.age".publicKeys = users ++ env-staging;

  # TODO: move common API keys into separate files
}
