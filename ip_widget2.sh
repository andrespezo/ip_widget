#!/bin/bash
# ip_widget.sh
# Muestra IP local, VPN y pública para usar en Genmon (XFCE)

# Interfaces a vigilar (ajusta a tu equipo: eth0, wlan0, tun0, etc.)
NORMAL_IFACE="eth0"
VPN_IFACE="tun0"

# Función: obtiene primera IPv4 de una interfaz si está activa
get_ip () {
  local iface="$1"
  if [[ -d "/sys/class/net/$iface" ]]; then
    local state=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
    if [[ "$state" == "up" || "$state" == "unknown" ]]; then
      ip -o -4 addr show dev "$iface" 2>/dev/null | awk '{print $4}' | cut -d'/' -f1 | head -n1
    fi
  fi
}

# IPs
LOCAL_IP=$(get_ip "$NORMAL_IFACE")
VPN_IP=$(get_ip "$VPN_IFACE")
PUBLIC_IP=$(curl -s ifconfig.me)

# Construir texto
TXT=""
TOOLTIP=""

if [[ -n "$LOCAL_IP" ]]; then
  TXT+="🌐 $LOCAL_IP "
   TOOLTIP+="Local ($NORMAL_IFACE): $LOCAL_IP\n"
fi

if [[ -n "$VPN_IP" ]]; then
  TXT+="🛡️ $VPN_IP "
  TOOLTIP+="VPN ($VPN_IFACE): $VPN_IP\n"
fi

if [[ -n "$PUBLIC_IP" ]]; then
  TXT+="🌍 $PUBLIC_IP"
  TOOLTIP+="Pública: $PUBLIC_IP\n"
fi

# Salida en formato XML para Genmon
echo "<txt>$TXT</txt><tool>$TOOLTIP</tool>"
