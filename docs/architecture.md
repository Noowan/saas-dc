# Архитектура

## Роли узлов

| Узел | Роль | Loopback | ASN/функция |
|---|---|---:|---|
| spine-1 | underlay eBGP, EVPN RR | 10.255.0.1/32 | global 65000, link local-as 65001 |
| spine-2 | underlay eBGP, EVPN RR | 10.255.0.2/32 | global 65000, link local-as 65002 |
| leaf-1 | VTEP, tenant gateway, EVPN MH peer | 10.255.0.11/32 | link local-as 65101 |
| leaf-2 | VTEP, tenant gateway, EVPN MH peer | 10.255.0.12/32 | link local-as 65102 |
| leaf-3 | VTEP, tenant gateway,  | 10.255.0.13/32 | link local-as 65103 |
| leaf-4 | VTEP, tenant gateway,  | 10.255.0.14/32 | link local-as 65104 |
| edge-leaf5 | VTEP，eBGP to Internet or other DC | 10.255.0.15/32 | link local-as 65105, AS1337 для пиринга с internet |
| leaf-6 | VTEP, tenant gateway, MLAG-emulation | 10.255.0.16/32 | link local-as 65106 |
| leaf-7 | VTEP, tenant gateway, MLAG-emulation | 10.255.0.17/32 | link local-as 65107 |
| internet | ISP router, internet emulator | 10.255.0.255/32 | AS 15169 |

Все BGP-процессы используют глобальный ASN 65000, чтобы overlay-сессии по loopback были iBGP. На underlay-сессиях меняется `local-as/remote-as` для eBGP.


## Linux хосты

| Имя | Описание | Адрес | Доп. информация |
|---|---|---|---|
| cl-a-vni10101-1 | Клиент А, leaf-1 | 10.10.10.11/24 | VNI 10101 |
| cl-a-vni10101-2 | Клиент А, leaf-2 | 10.10.10.12/24 | VNI 10101 |
| cl-a-vni10102-1 | Клиент А, leaf-4, приоритетный сегмент | 10.10.20.12/24 | VNI 10102 |
| cl-a-vni10102-mlag | Клиент А, leaf-6,leaf-7 MLAG пара | 10.10.20.60/32 | VNI 10102 |
| cl-b-vni20201-1 | Клиент Б, leaf-3 | 10.10.10.13/24 | VNI 20201 |
| cl-b-vni20201-2 | Клиент Б, leaf-4 | 10.10.10.14/24 | VNI 20201 |
| cl-b-vni20202-1 | Клиент Б, leaf-1, приоритетный сегмент | 10.10.20.11/24 | VNI 20202 |
| cl-b-vni20202-mh | Клиент Б, leaf-1,leaf-2 EVPN MH| 10.10.20.50/24 | VNI 20202 |
| 8-8-8-8 | хост с адресом 8.8.8.8 притворяющийся интернетом:) | 8.8.8.8/24 | ASN 15169 |
| mgmt-pc | хост для управления железом | 192.168.250.250/24 | ----- |



## Физические интерфейсы и адресация

| Линк | Левая сторона | Правая сторона | Назначение |
|---|---|---|---|
| spine-1 ↔ leaf-1 | 172.16.0.0/31 | 172.16.0.1/31 | underlay |
| spine-1 ↔ leaf-2 | 172.16.0.2/31 | 172.16.0.3/31 | underlay |
| spine-1 ↔ leaf-3 | 172.16.0.4/31 | 172.16.0.5/31 | underlay |
| spine-1 ↔ leaf-4 | 172.16.0.6/31 | 172.16.0.7/31 | underlay |
| spine-1 ↔ egde-leaf-5 | 172.16.0.8/31 | 172.16.0.9/31 | underlay |
| spine-1 ↔ leaf-6 | 172.16.0.10/31 | 172.16.0.11/31 | underlay |
| spine-1 ↔ leaf-7 | 172.16.0.12/31 | 172.16.0.13/31 | underlay |
| spine-2 ↔ leaf-1 | 172.16.1.0/31 | 172.16.1.1/31 | underlay |
| spine-2 ↔ leaf-2 | 172.16.1.2/31 | 172.16.1.3/31 | underlay |
| spine-2 ↔ leaf-3 | 172.16.1.4/31 | 172.16.1.5/31 | underlay |
| spine-2 ↔ leaf-4 | 172.16.1.6/31 | 172.16.1.7/31 | underlay |
| spine-2 ↔ egde-leaf-5 | 172.16.1.8/31 | 172.16.1.9/31 | underlay |
| spine-2 ↔ leaf-6 | 172.16.1.10/31 | 172.16.1.11/31 | underlay |
| spine-2 ↔ leaf-7 | 172.16.1.12/31 | 172.16.1.13/31 | underlay |
| edge-leaf-5 ↔ internet | 203.0.113.2/29 | 203.0.113.1/29 | eBGP |
| leaf-6 ↔ leaf-7 | L2 peer-link | L2 peer-link | MLAG, VLAN 201 |

Loopback подсеть: `10.255.0.0/24`. Линковки: `172.16.0.0/24`, `172.16.1.0/24`, хосты клиента А и Б `10.10.10.0/24`, `10.10.20.0/24` ,NAT `203.0.113.3-4/29`.

## VRF, VLAN, VNI, RT и Anycast Gateway

| VRF | VLAN | L2 VNI | L3 VNI | Подсеть | Anycast GW | RT |
|---|---:|---:|---:|---|---|---|
| CLIENT_A | 101 | 10101 | 10000 | 10.10.10.0/24 | 10.10.10.1 | 65000:10000 / 65000:10101 |
| CLIENT_A | 102 | 10102 | 10000 | 10.10.20.0/24 | 10.10.20.1 | 65000:10000 / 65000:10102 |
| CLIENT_B | 201 | 20201 | 20000 | 10.10.10.0/24 | 10.10.10.1 | 65000:20000 / 65000:20201 |
| CLIENT_B | 202 | 20202 | 20000 | 10.10.20.0/24 | 10.10.20.1 | 65000:20000 / 65000:20202 |

Anycast gateway MAC: `00:00:5e:00:01:01`, `00:1c:73:00:00:99`, `00:00:5e:02:01:01`, `00:00:5e:02:01:02`.
