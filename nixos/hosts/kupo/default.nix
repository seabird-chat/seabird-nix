{
  ...
}:
{
  # No hardware scan runs for a guest, so the platform is stated here instead
  # of coming from a hardware-configuration.nix.
  nixpkgs.hostPlatform = "x86_64-linux";

  # kupo is a MicroVM guest on eiko. It has no bootloader and no
  # hardware-configuration.nix: eiko's runner supplies the kernel, the initrd,
  # and init=, so the root filesystem below is what microvm.nix builds rather
  # than anything on a disk.
  microvm = {
    hypervisor = "qemu";
    vcpu = 2;

    # Not 2048: qemu hangs at exactly 2GB.
    # https://github.com/microvm-nix/microvm.nix/issues/171
    mem = 3072;

    # Sharing eiko's store read-only is what keeps the guest small and makes
    # the host's warm store count as the guest's warm store.
    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];

    # Everything worth keeping lives here: seabird's SQLite state and the SSH
    # host key that agenix decrypts with. The guest's / is a tmpfs, so a
    # service writing outside this volume loses its data on restart.
    volumes = [
      {
        mountPoint = "/var";
        image = "var.img";
        size = 8192;
      }
    ];

    # The tap is created on eiko by microvm-tap-interfaces@kupo, and eiko's
    # 11-microvm-seabird networkd file puts any vm-* link into br-seabird.
    # The MAC is fixed so the DHCP reservation stays valid across rebuilds.
    interfaces = [
      {
        type = "tap";
        id = "vm-kupo";
        mac = "02:00:00:00:40:01";
      }
    ];
  };

  networking = {
    hostName = "kupo";
    domain = "infra.seabird.chat";

    useNetworkd = true;
    useDHCP = false;
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Type = "ether";
    networkConfig.DHCP = "ipv4";
  };

  # / is a tmpfs, so sshd would generate a new host key on every boot and
  # agenix would lose the identity it decrypts with. Keeping the key on the
  # persistent /var volume is what makes the key survive a restart.
  services.openssh.hostKeys = [
    {
      path = "/var/lib/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  age.identityPaths = [ "/var/lib/ssh/ssh_host_ed25519_key" ];

  # No agenix secrets and no seabird services yet. The first boot exists to
  # produce the host key above; it gets added to secrets.nix, rekeyed, and only
  # then can this host hold anything.

  system.stateVersion = "26.05";
}
