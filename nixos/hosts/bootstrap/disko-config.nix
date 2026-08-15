{
  # Same layout the guests declare, so a deploy of the real configuration finds
  # the disk where it expects it.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";

    imageName = "bootstrap";
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
