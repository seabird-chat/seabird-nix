{
  ...
}:
{
  # Not generated: a guest has nothing to scan. eiko's libvirt domain decides
  # the platform and the devices, so they are stated here instead.
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;

  # The OVMF variable store belongs to the domain, so the guest should not write
  # EFI variables of its own.
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "sd_mod"
  ];

  # Serial console, so `virsh console` is a way back in when networking is the
  # thing that broke.
  boot.kernelParams = [
    "console=ttyS0,115200"
    "console=tty0"
  ];

  # Lets eiko ask for a clean shutdown and read the guest's state.
  services.qemuGuest.enable = true;
}
