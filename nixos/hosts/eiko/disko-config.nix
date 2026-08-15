{
  # Declarative disk layout, applied by nixos-anywhere's disko phase. The
  # device is addressed by id rather than /dev/sda, because the M93p also
  # sees USB media during an install.
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-SAMSUNG_SSD_830_Series_S0VVNEAC604690";

    content = {
      type = "gpt";

      partitions = {
        boot = {
          label = "boot";
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
          label = "root";
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
