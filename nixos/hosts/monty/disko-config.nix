{
  # Declarative disk layout for a libvirt guest. The domain gives it a single
  # virtio disk, so there is no need to address it by id the way eiko does.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";

    # Only used to build the image this guest is first provisioned from. 20G
    # because disko defaults to 2G, which a NixOS guest running seabird
    # overruns; the image is sparse.
    imageName = "monty";
    imageSize = "20G";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
