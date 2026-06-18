# rust.npi.msk.ru

Self-hosted RustDesk Server OSS for `rust.npi.msk.ru` on host `10.233.100.123`.

Canonical client path: every client uses the public name `rust.npi.msk.ru`, without split DNS or local exceptions.

```text
rust.npi.msk.ru -> 79.137.227.154
```

The RustDesk server itself is configured to resolve through the default DNS from the network (`10.233.100.1`), so it sees the same public name.

## Services

- `rustdesk-hbbs.service` - signal / ID server
- `rustdesk-hbbr.service` - relay server

`rustdesk-hbbs.service` has a systemd override:

```ini
[Service]
Environment=ALWAYS_USE_RELAY=Y
ExecStart=
ExecStart=/usr/bin/hbbs -r rust.npi.msk.ru:21117
```

`ALWAYS_USE_RELAY=Y` avoids direct P2P paths through mixed tunnels/proxies and routes sessions through `hbbr` instead.

Runtime data and RustDesk keys live in:

```text
/var/lib/rustdesk-server
```

Logs live in:

```text
/var/log/rustdesk-server
```

## Ports

Forward these ports from `79.137.227.154` to `10.233.100.123`:

- `21115/tcp` - NAT type test
- `21116/tcp` - TCP rendezvous / connection service
- `21116/udp` - ID registration / heartbeat
- `21117/tcp` - relay service

Optional web client ports:

- `21118/tcp`
- `21119/tcp`

`21114/tcp` is for RustDesk Server Pro web console and is not needed here.

## Client Settings

Use these RustDesk client network settings everywhere:

- ID Server: `rust.npi.msk.ru`
- Relay Server: `rust.npi.msk.ru`
- API Server: empty
- Key: contents of `/var/lib/rustdesk-server/id_ed25519.pub`

Current server public key:

```text
RoyN02+A6vR5lOyDU6UDF5ON7Fd38lCnRGw95+8AQbM=
```

RustDesk Server OSS does not use HTTPS/TLS on the domain. Clients verify the server using this RustDesk public key.

## Gateway NAT

Port forwarding is not a DNS feature. Apply NAT on the gateway that owns `79.137.227.154`:

- nftables template: `gateway/nftables-rustdesk.nft`
- iptables template: `gateway/iptables-rustdesk.sh`

For MikroTik, the equivalent is dst-nat for the TCP ports above and UDP `21116` to `10.233.100.123`.

## Useful Commands

```bash
systemctl status rustdesk-hbbs.service rustdesk-hbbr.service --no-pager -l
journalctl -u rustdesk-hbbs.service -u rustdesk-hbbr.service -n 100 --no-pager
ss -lntup | grep -E "2111[5-9]|hbbs|hbbr"
tail -n 100 /var/log/rustdesk-server/hbbs.log
tail -n 100 /var/log/rustdesk-server/hbbr.log
```
