# SaaS EVPN/VXLAN CLOS fabric

Воспроизводимая лабораторная топология ЦОД для SaaS-платформы: eBGP underlay, iBGP EVPN overlay, VXLAN, symmetric IRB, Anycast Gateway, изоляция клиентов с помощью VRF, OOB-сегмент, EVPN Multihoming All-Active и MLAG на отдельных leaf на Arista EOS т.к. FRR не поддерживает MLAG.

## Что входит

- 2 spine, 6 leaf, 1 edge-leaf(border/gateway) и 9 Linux хостов.
- Underlay eBGP и `/31` сети на всех линках, ECMP через оба spine.
- Overlay iBGP EVPN через spine, которые route-reflector для leaf.
- EVPN Type-2/Type-3/Type-5 для MAC/IP, BUM и L3 VRF routes. Type-1/Type-4 для Multihoming.
- Client-A и Client-B с одинаковыми подсетями `10.10.10.0/24` и `10.10.20.0/24`, но разными VRF/VNI/RT.
- `cl-b-vni20202-mh` подключён к leaf-1/leaf-2 в EVPN Multihoming All-Active.
- `cl-a-vni10102-mlag` подключён к leaf-6/leaf-7 (Arista EOS), которые являются MLAG парой.
- Отдельный OOB MGMT VRF на всех сетевых железках с отдельными линками в mgmt-sw. По-сути просто большой L2 сегмент для управления. Теоретически свитчей управления может быть несколько, там может быть какая-то маршрутизация, все сетевые железки подключены через консольные порты, а серверы через IPMI порт(ILO/IDRAC и т.д.) или через KVM консоль. В общем, вариантов много, главное, что действительно OOB. При проблемах с основной сетью ЦОД, железо остается доступным по управлению.
- MTU 9216 на транзитных интерфейсах и базовый QoS с помощью  Linux `tc`. 3 очереди для BE/EF/CS6+CS7 трафика. Весь трафик маркируется на входящих клиентских интерфейсах, сегмент с высокими требованиями к задержкам маркируется как EF и в него входят хосты `cl-b-vni20202-1` и `cl-a-vni10102-1` подключенные к eth5 leaf-1 и leaf-4 соответственно.



## Основные файлы
- `docs/saas-dc.drawio` - схема с физическими соединениями.
- `docs/architecture.md` — роли узлов, адресный план и VNI/VRF таблицы.
- `docs/design-decisions.md` — решения по ASN, RT/RD, DF election, ESI, MH, MLAG и QoS.
- `docs/runbook.md` — развёртывание, проверки, диагностика и graceful shutdown.
- `saas-dc.clab.yml` — файл топологии для containerlab в т.ч. бОльшая часть настроек в секциях exec для FRR железок с комментариями .
- `configs/*/frr.conf` — FRR конфигурации. Leaf-6/leaf-7 - startup-config для EOS.