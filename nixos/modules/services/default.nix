{
  imports = [
    ./seabird-core.nix

    # Backends
    ./seabird-discord-backend.nix
    ./seabird-irc-backend.nix

    # Plugins
    ./seabird-adventofcode-plugin.nix
    ./seabird-datadog-plugin.nix
    ./seabird-github-plugin.nix
    ./seabird-plugin-bundle.nix
    ./seabird-proxy-plugin.nix
    ./seabird-stock-plugin.nix
    ./seabird-url-plugin.nix

    # Other
    ./seabird-webhook-receiver.nix
  ];
}
