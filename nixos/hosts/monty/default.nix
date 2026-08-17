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

  system.stateVersion = "26.05";
}
