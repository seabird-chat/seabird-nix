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

`bootstrap` is not a host. It is the configuration a new guest is provisioned
from, described below.

`vivi` still runs the production seabird stack today. Moving it to `kupo` is the
next step.

## Deploying

```
nix develop -c deploy --remote-build -s .#kupo
```

`--remote-build` is there because the workstation is macOS and cannot build
Linux closures, so the target builds its own. Guests have two virtual CPUs, so
this is slow. Giving `eiko` a role as a remote builder would fix it and has not
been done yet.

## Bringing up a new guest

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
key. `secrets.nix` groups the recipients:

- `systems` is every host, for the login passwords and the nix daemon's netrc.
- `env-prod` is the hosts that run production seabird services, currently `kupo`
  and `vivi`.
- `env-staging` is `stiltzkin`, which gets its own copies of the seabird
  credentials rather than production's. Sharing them would put one bot identity
  on the network twice.

Per-host Datadog keys are readable only by the host they belong to.

Note that a host keeps its SSH host key across reinstalls if it is provisioned
with `--copy-host-keys`, so removing a host from a group does nothing until the
affected files are rekeyed.
