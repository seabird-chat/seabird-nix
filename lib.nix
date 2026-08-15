{
  self,
  nixpkgs,
  agenix,
  disko,
  ...
}:
let
  # mkLibvirtDomain renders a libvirt domain for a seabird guest. One template,
  # so prod and staging cannot drift apart in hardware shape.
  #
  # firmware='efi' lets libvirt pick OVMF from the descriptors NixOS installs,
  # and the emulator lives under /run/libvirt rather than in the store, so a
  # nixpkgs bump followed by a garbage collection cannot break a domain. Both
  # paths are provided by nixpkgs for exactly this purpose.
  mkLibvirtDomain =
    {
      name,
      uuid,
      mac,
      bridge,
      memory ? 4096,
      vcpu ? 2,
    }:
    ''
      <domain type='kvm'>
        <name>${name}</name>
        <uuid>${uuid}</uuid>
        <memory unit='MiB'>${toString memory}</memory>
        <vcpu placement='static'>${toString vcpu}</vcpu>
        <os firmware='efi'>
          <type arch='x86_64' machine='q35'>hvm</type>
          <boot dev='hd'/>
        </os>
        <features>
          <acpi/>
          <apic/>
        </features>
        <cpu mode='host-passthrough' check='none' migratable='off'/>
        <clock offset='utc'/>
        <on_poweroff>destroy</on_poweroff>
        <on_reboot>restart</on_reboot>
        <on_crash>restart</on_crash>
        <pm>
          <suspend-to-mem enabled='no'/>
          <suspend-to-disk enabled='no'/>
        </pm>
        <devices>
          <emulator>/run/libvirt/nix-emulators/qemu-system-x86_64</emulator>
          <disk type='file' device='disk'>
            <driver name='qemu' type='raw' cache='none' io='native' discard='unmap'/>
            <source file='/var/lib/libvirt/images/${name}.img'/>
            <target dev='vda' bus='virtio'/>
          </disk>
          <interface type='bridge'>
            <source bridge='${bridge}'/>
            <mac address='${mac}'/>
            <model type='virtio'/>
            <target dev='vm-${name}'/>
          </interface>
          <serial type='pty'>
            <target port='0'/>
          </serial>
          <console type='pty'>
            <target type='serial' port='0'/>
          </console>
          <channel type='unix'>
            <target type='virtio' name='org.qemu.guest_agent.0'/>
          </channel>
          <memballoon model='virtio'/>
        </devices>
      </domain>
    '';
in
{
  inherit mkLibvirtDomain;

  mkNixosSystem =
    { modules }:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit self mkLibvirtDomain;
      };

      modules = [
        self.nixosModules.default
        agenix.nixosModules.default
        disko.nixosModules.disko
      ]
      ++ modules;
    };

  # mkNixosDeploy takes a nixosConfig, generated using mkNixosSystem, and
  # generates an opinionated deploy-rs config.
  mkNixosDeploy =
    nixosConfig:
    let
      pkgs = nixosConfig._module.args.pkgs;
    in
    {
      user = "root";
      sshUser = "root";
      path = pkgs.deploy-rs.lib.activate.nixos nixosConfig;
    };
}
