{
  config,
  ...
}:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  # This is not a host. It is the image a new guest is provisioned from: it
  # exists to boot, get an address, and accept a deploy of the real
  # configuration, which replaces it entirely.
  #
  # A guest cannot be provisioned from its own configuration and then deployed
  # to, because its agenix secrets need an SSH host key that only exists after
  # the first boot. So the first boot happens here, with no secrets at all.
  networking = {
    hostName = "bootstrap";
    domain = "infra.seabird.chat";

    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "ipv4";

    # DHCP reservations are per MAC and the domain fixes that, so a guest booted
    # from this image lands on the address meant for it even though the hostname
    # is still "bootstrap".
    dhcpV4Config.ClientIdentifier = "mac";
  };

  # hunter2 is deliberately a joke password. The point is a way in on the
  # serial console before any secret can be decrypted; nothing here is
  # sensitive, and this configuration is never deployed to a running guest.
  users.users.belak = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "hunter2";
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };

  users.users.root.password = "hunter2";

  # The console is the reason the password exists. Keep it off the network,
  # since this image sits on the seabird VLAN with everything else.
  services.openssh.settings.PasswordAuthentication = false;

  system.stateVersion = "26.05";
}
