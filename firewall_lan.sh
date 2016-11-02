#!/bin/bash

EXTERNAL_IF=“enp0s3”
INTERNAL_IF=“enp0s8”
INTERNAL_NET=“192.168.0.0/24”


# Apagando todas as regras

iptables –F
iptables –t nat -F

# Configurando as regras padrão para DROP para INPUT e FORWARD

iptables –P INPUT DROP
iptables –P FORWARD DROP

# Permitindo conexões ESTABLISHED e RELATED
iptables –A INPUT –m state -–state ESTABLISHED,RELATED –j ACCEPT
iptables –A FORWARD –m state -–state ESTABLISHED,RELATED –j ACCEPT

# Permitindo conexao irrestrita da interface loopback
iptables –A INPUT –i lo –j ACCEPT
iptables –A FORWARD -i lo -o lo –m state -–state ESTABLISHED,RELATED –j ACCEPT

# Permitindo acesso SSH ao Firewall a partir da rede Internal

iptables –A INPUT –i $INTERNAL_IF –s $INTERNAL_NET –p tcp –-dport 22 –j ACCEPT


# Permitindo que os hosts da rede Internal acessem os serviços HTTP, HTTPS e DNS externamente

iptables –A FORWARD –i $INTERNAL_IF –s $INTERNAL_NET –p tcp –m multiport -–dports 80,443 –j ACCEPT
iptables –A FORWARD –i $INTERNAL_IF –s $INTERNAL_NET –p udp –m multiport -–dports 53 –j ACCEPT


# Mascarando pacotes oriundos da rede interna

iptables –t nat –A POSTROUTING –s $INTERNAL_NET –j MASQUERADE –o $EXTERNAL_IF


# Permitindo ICMP a partir da rede interna com destino a internet e firewall

iptables –A INPUT –i $INTERNAL_IF –s $INTERNAL_NET –p icmp –j ACCEPT
iptables –A FORWARD –i $INTERNAL_IF –s $INTERNAL_NET –p icmp –j ACCEPT


# Permitindo acesso externo ao serviço de SSH a partir de um host da Rede Interna

iptables –A FORWARD –i $INTERNAL_IF –s 192.168.0.10 –p tcp –-dport 22 –j ACCEPT


# Negando o acesso a um site especifico.

iptables –I FORWARD 1 –i $INTERNAL_IF –s $INTERNAL_NET –d www.uol.com.br –p tcp –-dport 80 –j ACCEPT
