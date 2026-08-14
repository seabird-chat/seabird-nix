{
  self,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "eiko";
    domain = "infra.seabird.chat";

    # systemd-networkd allows for easier bridge configuration, which we need for
    # when we start introducing microvms.
    useNetworkd = true;

    # The global DHCP client is off so no lease is requested for the bridge
    # itself, which would blackhole guest traffic.
    useDHCP = false;

    # eno1 is untagged on the seabird VLAN, so the bridge needs no tagged
    # subinterface. eiko's own address moves onto the bridge, which is why
    # eno1 no longer asks for a lease of its own.
    bridges.br-seabird.interfaces = [ "eno1" ];
    interfaces.br-seabird.useDHCP = true;

    # A bridge does not inherit eno1's address here: udev's 99-default.link
    # applies MACAddressPolicy=persistent to every link, and a bridge on this
    # box does get a generated MAC (verified: the same one on each recreation).
    # Taking eno1's keeps the address the router already knows.
    interfaces.br-seabird.macAddress = "d8:cb:8a:cf:e5:23";
  };

  # DHCP moves from eno1 to the bridge, and networkd's default client
  # identifier is DUID+IAID, where the IAID depends on the interface. That
  # would present eiko as a new client and could change its address, so
  # identify by MAC instead: with the MAC pinned above, the lease keeps working.
  systemd.network.networks."40-br-seabird".dhcpV4Config.ClientIdentifier = "mac";

  # Guest taps are created by microvm-tap-interfaces@ at VM start, so match on
  # the name prefix rather than naming each guest here. Scripted networking
  # cannot do this, which is why the host runs networkd.
  systemd.network.networks."11-microvm-seabird" = {
    matchConfig.Name = "vm-*";
    networkConfig.Bridge = "br-seabird";
    linkConfig.RequiredForOnline = "no";
  };

  microvm = {
    autostart = [ "kupo" ];

    # `flake = self` deploys the guest from this flake's nixosConfigurations.
    # /var/lib/microvms/kupo is only created if absent, so later guest changes
    # go out with `deploy .#kupo`; the host only owns the kernel, the initrd,
    # and the runner.
    vms.kupo = {
      flake = self;
      updateFlake = "github:seabird-chat/seabird-nix";
    };
  };

  services.datadog-agent = {
    enable = true;
    site = "datadoghq.com";
    apiKeyFile = config.age.secrets.datadog-api-key.path;
    extraConfig = {
      env = "production";
      dogstatsd_port = 8125;
    };
  };

  age.secrets.datadog-api-key = {
    file = ../../../secrets/datadog-key-eiko.age;
    owner = "datadog";
  };

  # The MicroVM guests mount this host's /nix/store read-only, so every
  # closure they run has to be here first. Building it into eiko's own system
  # closure warms the store and keeps nix.gc from collecting it between the
  # time a guest is defined and the time its services are enabled. Staging is
  # included so stiltzkin costs nothing extra later.
  system.extraDependencies = lib.attrValues pkgs.seabird ++ lib.attrValues pkgs.seabird-staging;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
