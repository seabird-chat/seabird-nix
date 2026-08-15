{
  self,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  # Seabird staging, deliberately the same shape as kupo. Staging will need its
  # own credentials rather than prod's, or one bot identity ends up connected
  # twice.
  networking = {
    hostName = "stiltzkin";
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

  # Builds the staging packages into this guest's store ahead of needing them,
  # so the deploy that enables the services only has to activate. Costs one long
  # deploy now, since --build-on remote means the guest builds them itself.
  system.extraDependencies = [ self.packages.x86_64-linux.all-staging ];

  system.stateVersion = "26.05";
}
