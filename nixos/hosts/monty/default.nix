{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  # The staging environment's dependencies, rather than a third seabird
  # environment. Things staging needs to test against but that are not seabird:
  # an IRC daemon first, and whatever a later backend needs to talk to.
  #
  # It exists so staging can be tested destructively. Pointing staging at the
  # real IRC network means every restart, netsplit and command test is visible
  # to real users, and needs a nick and a NickServ password from that network's
  # admin. A private IRCd needs neither.
  #
  # Deliberately not on stiltzkin: prod and staging have to mirror each other,
  # so a staging failure is a code failure and not a difference in plumbing. A
  # daemon running beside the services under test is exactly such a difference.
  #
  # No agenix secrets yet: the host key is generated at first boot, then added
  # to secrets.nix and rekeyed. The belak user's password is an agenix file, so
  # the first deploy has to wait for that rekey.
  networking = {
    hostName = "monty";
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

  # Staging's dependencies are part of staging as far as monitoring is
  # concerned, so this reports under the same env as stiltzkin.
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
    file = ../../../secrets/hosts/datadog-key-monty.age;
    owner = "datadog";
  };

  # Staging's IRC network. Ergo rather than UnrealIRCd, which the real network
  # runs: Unreal is not in nixpkgs and needs Atheme alongside it for services,
  # while Ergo is one Go binary with NickServ and ChanServ built in. Nothing is
  # lost by the difference today, because seabird-irc-backend negotiates no
  # capabilities at all -- it registers with PASS/NICK/USER and optionally
  # identifies to NickServ. That changes when the IRCv3 work lands, and then
  # packaging Unreal starts to earn its keep.
  #
  # Most of what this needs is already the nixpkgs module's default, including
  # account and channel registration, history, and a database created on first
  # start. Only the identity, the listener and one default are set here.
  services.ergochat = {
    enable = true;

    settings = {
      network.name = "seabird-staging";

      server = {
        name = "monty.infra.seabird.chat";

        # Plaintext, because this is reachable only from the seabird VLAN and
        # zidane terminates TLS for everything that faces outward. A client
        # elsewhere comes in through soju on zidane rather than directly. The
        # seabird backend uses this one.
        listeners.":6667" = { };

        # TLS, for the one thing plaintext cannot do: SASL EXTERNAL. Ergo
        # rejects an EXTERNAL attempt from a session with no client
        # certificate, so certificate login needs a TLS listener even on a
        # private network. The cert is self-signed and soju pins it by
        # fingerprint, which is why no CA and no ACME credential are involved.
        listeners.":6697".tls = {
          cert = "/var/lib/ergo/tls.crt";
          key = "/var/lib/ergo/tls.key";
        };
      };

      # The module defaults to always-on for registered accounts, which makes a
      # nick stay present after its client disconnects. That is bouncer
      # behaviour, and it would make a reconnecting bot collide with its own
      # lingering nick, so a test network should behave like a plain ircd until
      # someone asks otherwise.
      accounts.multiclient.always-on = "opt-in";
    };
  };

  networking.firewall.allowedTCPPorts = [
    6667
    6697
  ];

  # Generated once, on first start, and then left alone: soju pins this cert by
  # fingerprint, so replacing it means re-pinning. `ergo mkcerts` would do the
  # same job but issues 365-day certs and aborts when the files already exist,
  # neither of which suits something pinned and long-lived.
  systemd.services.ergochat.serviceConfig.ExecStartPre = [
    (pkgs.writeShellScript "ergo-self-signed-cert" ''
      set -eu
      cert="$STATE_DIRECTORY/tls.crt"
      key="$STATE_DIRECTORY/tls.key"

      if [ -f "$cert" ] && [ -f "$key" ]; then
        exit 0
      fi

      ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -sha256 \
        -days 3650 -nodes \
        -keyout "$key" -out "$cert" \
        -subj "/CN=monty.infra.seabird.chat/O=seabird-staging" \
        -addext "subjectAltName=DNS:monty.infra.seabird.chat,IP:192.168.40.6"

      chmod 0600 "$key"
      chmod 0644 "$cert"
    '')
  ];

  system.stateVersion = "26.05";
}
