{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.seabird.hardware.raspberry-pi-4;
in
{
  options = {
    seabird.hardware.raspberry-pi-4.enable = lib.mkEnableOption "Raspberry Pi 4";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;

    # All of these modules are needed in order to boot from a USB drive.
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "uas" # usb_storage but newer
      "pcie_brcmstb" # needed for the PCIe bus to work
      "reset_raspberrypi" # needed to get the VL805 USB controller firmware to load

    ];

    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };

    swapDevices = [ ];

    # Raspberry Pi 4 related tweaks
    console.enable = false;

    environment.systemPackages = with pkgs; [
      libraspberrypi
      raspberrypi-eeprom
    ];

    networking.interfaces.end0.useDHCP = lib.mkDefault true;

    hardware.enableRedistributableFirmware = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
