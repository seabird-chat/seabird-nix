{
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
        # elsewhere comes in through soju on zidane rather than directly.
        listeners.":6667" = { };
      };

      # The module defaults to always-on for registered accounts, which makes a
      # nick stay present after its client disconnects. That is bouncer
      # behaviour, and it would make a reconnecting bot collide with its own
      # lingering nick, so a test network should behave like a plain ircd until
      # someone asks otherwise.
      accounts.multiclient.always-on = "opt-in";
    };
  };

  networking.firewall.allowedTCPPorts = [ 6667 ];

  system.stateVersion = "26.05";
}
