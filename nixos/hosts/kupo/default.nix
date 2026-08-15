{
  self,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  # Seabird production. No agenix secrets yet: the host key is generated at
  # first boot, then added to secrets.nix and rekeyed.
  networking = {
    hostName = "kupo";
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

  # Builds the release packages into this guest's store ahead of needing them,
  # so the deploy that enables the services only has to activate. Costs one long
  # deploy now, since --build-on remote means the guest builds them itself.
  system.extraDependencies = [ self.packages.x86_64-linux.all-prod ];

  system.stateVersion = "26.05";
}
