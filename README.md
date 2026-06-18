# rust.npi.msk.ru

Self-hosted RustDesk Server OSS for `rust.npi.msk.ru` on host `10.233.100.123`.

This host runs the native Debian packages, not Docker. Docker cannot run containers in this environment because `runc` cannot mount `/proc`.

## Services

- `rustdesk-hbbs.service` - signal / ID server
- `rustdesk-hbbr.service` - relay server

`rustdesk-hbbs.service` has a systemd override:

```ini
[Service]
ExecStart=
ExecStart=/usr/bin/hbbs -r rust.npi.msk.ru:21117
```

Runtime data and RustDesk keys live in:

```text
/var/lib/rustdesk-server
```

Logs live in:

```text
/var/log/rustdesk-server
```

## Ports

Forward these ports directly to `10.233.100.123`:

- `21115/tcp` - NAT type test
- `21116/tcp` - TCP hole punching / connection service
- `21116/udp` - ID registration / heartbeat
- `21117/tcp` - relay service

Optional web client ports:

- `21118/tcp`
- `21119/tcp`

`21114/tcp` is for RustDesk Server Pro web console and is not needed here.

## Client Settings

Use these RustDesk client network settings:

- ID Server: `rust.npi.msk.ru`
- Relay Server: empty, or `rust.npi.msk.ru`
- Key: contents of `/var/lib/rustdesk-server/id_ed25519.pub`

Current server public key:

```text
RoyN02+A6vR5lOyDU6UDF5ON7Fd38lCnRGw95+8AQbM=
```

RustDesk Server OSS does not use HTTPS/TLS on the domain. Clients verify the server using this RustDesk public key.

## Useful Commands

```bash
systemctl status rustdesk-hbbs.service rustdesk-hbbr.service --no-pager -l
journalctl -u rustdesk-hbbs.service -u rustdesk-hbbr.service -n 100 --no-pager
ss -lntup | grep -E "2111[5-9]|hbbs|hbbr"
```

## Gateway NAT

DNS should point `rust.npi.msk.ru` to `79.137.227.154`.

Port forwarding is not a DNS feature. Apply NAT on the gateway that owns `79.137.227.154` / `10.233.100.1`:

- nftables template: `gateway/nftables-rustdesk.nft`
- iptables template: `gateway/iptables-rustdesk.sh`

The NAT rules include hairpin NAT, so clients inside `10.233.100.0/24` can also use `rust.npi.msk.ru` through the public IP.

## Internal DNS

Internal/tunnel clients should use DNS server `10.233.100.101`.

That DNS server resolves:

```text
rust.npi.msk.ru -> 10.233.100.123
```

The RustDesk host itself is configured to use `10.233.100.101` via `/etc/resolv.conf` and `/etc/dhcp/dhclient.conf`.
