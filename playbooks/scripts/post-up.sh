#!/bin/bash

# Script obtained from https://www.reddit.com/r/WireGuard/comments/1baeuyx/wireguard_oracle_cloud_step_by_step/


IPT="/sbin/iptables"
IPT6="/sbin/ip6tables"

# Added way to programatically get default network interface
IN_FACE=$(ip route | grep default | tail -n 1 | awk '{print $5}')                # NIC connected to the internet
WG_FACE="wg0"                    # WG NIC
SUB_NET="10.0.0.0/24"          # WG IPv4 sub/net aka CIDR
WG_PORT="51820"                  # WG udp port


## IPv4 ##
#$IPT -t nat -I POSTROUTING 1 -s $SUB_NET -o $IN_FACE -j MASQUERADE # insert rule at the start of the postrounting chain in NAT table.
#$IPT -I INPUT 1 -i $WG_FACE -j ACCEPT
#$IPT -I FORWARD 1 -i $IN_FACE -o $WG_FACE -j ACCEPT
#$IPT -I FORWARD 1 -i $WG_FACE -o $IN_FACE -j ACCEPT
#$IPT -I INPUT 1 -i $IN_FACE -p udp --dport $WG_PORT -j ACCEPT

nft add rule nat postrouting ip saddr $SUB_NET oif $IN_FACE masquerade 
nft add rule filter INPUT iif $IN_FACE accept
nft add rule filter FORWARD iif $IN_FACE oif $WG_FACE accept 
nft add rule filter FORWARD iif $WG_FACE oif $IN_FACE accept
nft add rule filter INPUT iif $IN_FACE udp dport $WG_PORT accept
