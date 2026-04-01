#!/usr/bin/env bash
set -e

# Detect WAN interface by relay IP (interface_name requires Docker Engine v28.1+)
WAN_IF=$(ip -o addr show | awk -v ip="${RELAY_IP}" '$4 ~ ("^" ip "/") {print $2; exit}')
echo "WAN interface: ${WAN_IF} (relay IP: ${RELAY_IP})" >&2

# Set route to dialer subnet
echo "Setting route to dialer subnet ${DIALER_LAN_SUBNET} via ${DIALER_ROUTER_IP}" >&2
ip route add "${DIALER_LAN_SUBNET}" via "${DIALER_ROUTER_IP}" dev "${WAN_IF}"

# Set route to listener subnet
echo "Setting route to listener subnet ${LISTENER_LAN_SUBNET} via ${LISTENER_ROUTER_IP}" >&2
ip route add "${LISTENER_LAN_SUBNET}" via "${LISTENER_ROUTER_IP}" dev "${WAN_IF}"

# Execute the relay binary, passing through all arguments
exec /usr/local/bin/relay "$@"
