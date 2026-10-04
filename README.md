# seabird-nix

A package repo and overlay with a basic version of all seabird packages, plus
the NixOS configuration for the hosts seabird runs on.

## Hosts

`eiko` is a physical machine that does two things: it runs libvirt, and it owns
the `br-seabird` bridge that puts guests on the seabird VLAN. It runs no seabird
services itself, and it cannot read their credentials.

`kupo` and `stiltzkin` are virtual machines on `eiko`, production and staging.
They are ordinary NixOS hosts with their own disks, bootloaders and stores, so
`deploy` treats them like any other machine: it copies a closure over SSH,
activates it in place, and restarts only the services whose definitions changed.
That last part is the reason they are full VMs rather than something lighter. A
deploy that restarted the whole guest would drop every IRC and Discord
connection, and both MicroVMs and NixOS containers can only apply a change that
way.

`atla` is a Vultr instance using the raw UEFI `vultr-bootstrap-image` layout.
The image and host share `nixos/profiles/vultr.nix` for their disk and boot
settings, separate from the libvirt guests' Disko layout.

`bootstrap` is not a host. It is the configuration a new libvirt guest is
provisioned from, described below.

`vivi` used to run the production stack and is no longer managed here. It was
handed back to `belak/dotfiles` once `kupo` took over, so this flake describes
only the seabird machines.

## Deploying

```
nix develop -c deploy --remote-build -s .#kupo
```

`--remote-build` is there because the workstation is macOS and cannot build
Linux closures, so the target builds its own. Guests have two virtual CPUs, so
this is slow. Giving `eiko` a role as a remote builder would fix it and has not
been done yet.

### Deploying atla

Atla mounts its existing ext4 root by filesystem label `nixos` and its EFI
partition by label `ESP`. Keep those labels: the snapshot does not have the
`disk-main-root` and `disk-main-ESP` partition labels used by the libvirt guests.
Do not run Disko or repartition the instance when deploying this configuration.

Systemd-boot keeps the UEFI fallback boot path without writing firmware
variables. Its menu is limited to two generations for the small EFI partition.
The root partition and filesystem grow to use the available disk space on boot.

Register the instance's SSH host key and rekey its agenix secrets before the
first deploy, then run:

``` shell
deploy --remote-build -s .#atla
```

The Seabird services are disabled in Atla's initial configuration. Stop the old
production services before enabling the same bot identities on Atla.

## Bringing up a Vultr instance

Build the secret-free image on an x86-64 Linux machine:

``` shell
nix build .#vultr-bootstrap-image
```

The output is `result/nixos-vultr.img`, a raw UEFI disk image sized for its
contents. Building requires an x86-64 Linux builder; it cannot run directly on
macOS. The image uses the same filesystem labels, bootloader, disk expansion,
and VirtIO support as Atla.

Root SSH accepts the public keys in `secrets/keys.nix`'s `users` list at build
time. Password login is disabled, and SSH host keys are generated on boot.
The image contains no agenix secrets or Seabird services. It uses DHCP without
cloud-init, so Vultr-selected SSH keys, passwords, and user-data are not applied.

Host the raw image at a URL Vultr can download, then import it as a snapshot:

``` shell
vultr-cli snapshot create-url --url https://example.com/nixos-vultr.img --uefi
```

Launch an instance from the snapshot with a disk at least as large as the image
and inbound TCP port 22 allowed. Remove the hosted copy once Vultr finishes
importing it. Connect as root, register the new SSH host key, and follow
[Deploying atla](#deploying-atla) to replace the bootstrap configuration.
Use the image only for new instances; deploy-rs updates existing installations
without replacing their disks.

## Bringing up a libvirt guest

A guest cannot be provisioned directly from its own configuration, because that
configuration needs an agenix secret and agenix decrypts with the guest's SSH
host key, which does not exist until the guest has booted once. So the first
boot happens on the `bootstrap` configuration, which has no secrets at all and a
console password.

One image serves every guest. DHCP reservations are per MAC and the libvirt
domain fixes that, so a guest booted from this image still lands on the address
meant for it despite calling itself `bootstrap`.

Build the image on `eiko`, since it needs an `x86_64-linux` machine, and install
it as the guest's disk:

```
nix build --no-link --print-out-paths github:seabird-chat/seabird-nix#bootstrap-image
install -m 600 <result>/bootstrap.raw /var/lib/libvirt/images/kupo.img
```

Use `install` rather than `cp`. Store paths are read-only, and `cp` preserves
that, which leaves the guest unable to write to its own disk. The image is also
only for first provisioning: once a guest has booted, its disk is live state and
deploys own it, so writing a fresh image over it would roll the guest back to
the day it was born.

Then define the domain. `eiko`'s configuration renders the XML into
`/etc/seabird/domains`, so there is nothing to write by hand:

```
virsh define /etc/seabird/domains/kupo.xml
virsh autostart kupo
virsh start kupo
virsh console kupo     # belak or root, password hunter2, ctrl-] to leave
```

`virsh autostart` is what starts the guest after a reboot. libvirt's other
mechanism, the `libvirt-guests` service, is deliberately told to ignore boot, so
exactly one thing decides whether a guest comes back. It still handles the
shutdown side, where it asks each guest to power off through ACPI so seabird can
exit cleanly and close its databases.

Add a DHCP reservation for the MAC in the domain, then register the guest's new
host key before deploying to it:

```
ssh root@zidane.elwert.dev 'ssh-keyscan -t ed25519 kupo.infra.seabird.chat'
```

Run the scan from `zidane` rather than your workstation. `ssh-keyscan` does not
read `ProxyJump` from your SSH config, and the workstation cannot reach the
seabird VLAN directly.

Add that key to `secrets.nix`, run `agenix --rekey`, and only then deploy. The
guests carry the `belak` user, whose password is an agenix secret, so a deploy
before the rekey fails on a secret the guest cannot read.

### Redefining a domain

libvirt rewrites parts of a definition when you define or start it. `machine`
becomes a versioned type such as `pc-q35-10.2`, and `firmware='efi'` is expanded
into concrete firmware paths. A large enough qemu upgrade can leave a domain
pinned to a machine type that no longer exists, and it will refuse to start
until you define it again from `/etc/seabird/domains`. That is why the XML is
generated and kept rather than treated as one-time setup.

Because of the same rewriting, comparing a running domain against its source
shows differences that are expected:

```
virsh dumpxml kupo | diff -u /etc/seabird/domains/kupo.xml -
```

## Secrets

Secrets are agenix files under `secrets/`, decrypted with each host's SSH host
key, and grouped into a directory per scope:

- `common/` is readable by every host: the login passwords and the nix daemon's
  netrc.
- `hosts/` is one file per machine, readable only by that machine. The Datadog
  keys live here so a compromised guest cannot report as another.
- `prod/` and `staging/` hold the seabird service credentials for each
  environment. Staging gets its own copies rather than sharing prod's, since
  sharing them would put one bot identity on the network twice.

The same service appears under both `prod/` and `staging/` with the same
filename, so `diff <(ls secrets/prod) <(ls secrets/staging)` shows what staging
still needs.

`secrets.nix` names the recipients per file. `env-prod` is currently just
`kupo`, and `env-staging` just `stiltzkin`.

Every service module takes a required `secretFile`, so a host states which file
it uses and there is no default to fall back to. `package` does default, to the
prod build, which a staging host overrides with the matching
`pkgs.seabird-staging` package.

Note that a host keeps its SSH host key across reinstalls if it is provisioned
with `--copy-host-keys`, so removing a host from a group does nothing until the
affected files are rekeyed.
