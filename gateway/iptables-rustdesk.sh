#!/bin/sh
set -eu

WAN_IP=79.137.227.154
RUST_HOST=10.233.100.123
LAN_NET=10.233.100.0/24

iptables -t nat -A PREROUTING -d "$WAN_IP" -p tcp -m multiport --dports 21115,21116,21117,21118,21119 -j DNAT --to-destination "$RUST_HOST"
iptables -t nat -A PREROUTING -d "$WAN_IP" -p udp --dport 21116 -j DNAT --to-destination "$RUST_HOST"

iptables -A FORWARD -d "$RUST_HOST" -p tcp -m multiport --dports 21115,21116,21117,21118,21119 -j ACCEPT
iptables -A FORWARD -d "$RUST_HOST" -p udp --dport 21116 -j ACCEPT

# Hairpin NAT for LAN clients using rust.npi.msk.ru via public IP.
iptables -t nat -A POSTROUTING -s "$LAN_NET" -d "$RUST_HOST" -p tcp -m multiport --dports 21115,21116,21117,21118,21119 -j MASQUERADE
iptables -t nat -A POSTROUTING -s "$LAN_NET" -d "$RUST_HOST" -p udp --dport 21116 -j MASQUERADE
