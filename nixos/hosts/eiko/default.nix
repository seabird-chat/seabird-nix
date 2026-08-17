{
  config,
  lib,
  mkLibvirtDomain,
  ...
}:

let
  guests = {
    kupo = {
      uuid = "7c1f4a52-2f0e-4a6b-9d55-2b8c5d4f1a01";
      mac = "02:00:00:00:40:01";
    };

    stiltzkin = {
      uuid = "7c1f4a52-2f0e-4a6b-9d55-2b8c5d4f1a02";
      mac = "02:00:00:00:40:02";
    };

    # Staging's dependencies, not a third seabird environment, so it sits at
    # .6 beside eiko rather than continuing the .10 / .20 run.
    monty = {
      uuid = "7c1f4a52-2f0e-4a6b-9d55-2b8c5d4f1a03";
      mac = "02:00:00:00:40:03";
    };
  };
in
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "eiko";
    domain = "infra.seabird.chat";

    # systemd-networkd makes the bridge and the guest taps much easier to
    # configure than scripted networking does.
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

  seabird.atticCache.enable = true;

  services.datadog-agent = {
    enable = true;
    site = "datadoghq.com";
    apiKeyFile = config.age.secrets.datadog-api-key.path;
    extraConfig = {
      env = "prod";
      dogstatsd_port = 8125;
    };
  };

  age.secrets.datadog-api-key = {
    file = ../../../secrets/hosts/datadog-key-eiko.age;
    owner = "datadog";
  };

  # libvirt creates each guest's tap as vm-<name> when the domain starts, so
  # match on the prefix rather than naming every guest here.
  systemd.network.networks."11-vm-seabird" = {
    matchConfig.Name = "vm-*";
    networkConfig.Bridge = "br-seabird";
    linkConfig.RequiredForOnline = "no";
  };

  # eiko is the hypervisor and the bridge host, nothing more. The guests are
  # ordinary NixOS nodes deployed over SSH, so a deploy activates in place and
  # restarts only the units that changed.
  #
  # The domains are generated into /etc/seabird/domains and defined by hand,
  # once per guest, along with their disk images.
  environment.etc = lib.mapAttrs' (
    name: guest:
    lib.nameValuePair "seabird/domains/${name}.xml" {
      text = mkLibvirtDomain (
        guest
        // {
          inherit name;
          bridge = "br-seabird";
        }
      );
    }
  ) guests;

  # Boot state is decided only by each domain's autostart flag, so
  # libvirt-guests must not also restore whatever happened to be running. It
  # keeps its job on the way down, where an ACPI shutdown lets each guest stop
  # seabird cleanly and close its SQLite databases.
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    shutdownTimeout = 120;
    parallelShutdown = 2;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
