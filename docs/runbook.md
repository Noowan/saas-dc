
# Runbook
## Все тестировалось на Ubuntu server 26.04 (minimal) 

## Предварительные условия

Проверяем, что в системе нет ничего лишнего, что может конфликтовать с Docker

```sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)```

Добавляем репозиторий Docker 

```sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

Ставим Docker

```sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin```

Проверяем, что Docker работает

```sudo docker version```

Ожидаем подобный вывод:
```
Client: Docker Engine - Community
 Version:           29.9.2
 API version:       1.56
 Go version:        go1.26.10
 Git commit:        a82e528
 Built:             Tue Oct 20 18:45:12 2026
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          29.9.2
  API version:      1.56 (minimum version 1.40)
  Go version:       go1.26.10
  Git commit:       0367cbe
  Built:            Tue Oct 20 18:45:12 2026
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.4.2
  GitCommit:        b7a25261e029d68978bbf290df0a62fc819b3c51
 runc:
  Version:          1.5.2
  GitCommit:        v1.5.2-0-g29dd3dc2
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

Пробуем запустить контейнер:

```
sudo docker run hello-world
```

Ожидаем после скачивания контейнера:
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

Устанавливаем containerlab и добавляем себя в группу clab_admins:

```sudo bash -c "$(curl -sL https://get.containerlab.dev)"```
```
USER=$(whoami)
sudo usermod -aG clab_admins $USER
getent group clab_admins
```

Ожидаем свое имя пользователя в конце списка:
```
afedotov@test:~$ getent group clab_admins
clab_admins:x:986:root,afedotov
```

Проверяем, что containerlab установлен:
```
clab version
```

Теперь нужно проверить, что containerlab работает.

```
mkdir -p /home/$USER/.clab/test-topo
cd /home/$USER/.clab/test-topo
```
Создаем тестовую топологию:
```
cat <<EOF > test.clab.yml
name: test-lab

topology:
  nodes:
    node1:
      kind: linux
      image: alpine:latest
    node2:
      kind: linux
      image: alpine:latest

  links:
    - endpoints: ["node1:eth1", "node2:eth1"]
EOF
```
И запускаем её:
```
clab deploy
```

Ожидаем:
```
╭─────────────────────┬───────────────┬─────────┬───────────────────╮
│         Name        │   Kind/Image  │  State  │   IPv4/6 Address  │
├─────────────────────┼───────────────┼─────────┼───────────────────┤
│ clab-test-lab-node1 │ linux         │ running │ 172.20.20.2       │
│                     │ alpine:latest │         │ 3fff:172:20:20::2 │
├─────────────────────┼───────────────┼─────────┼───────────────────┤
│ clab-test-lab-node2 │ linux         │ running │ 172.20.20.3       │
│                     │ alpine:latest │         │ 3fff:172:20:20::3 │
╰─────────────────────┴───────────────┴─────────┴───────────────────╯
```

Останавливаем тестовую топологию:
```
clab destroy --cleanup
```

## Развертывание

Копируем проект в папку /home/$USER/.clab/
Например с помощью sftp.
Заходим в папку с проектом
```
cd /home/$USER/.clab/saas-dc
```
И запускаем нашу лабу. Запуск может быть долгим из-за импорта контейнера Arisa EOS!!!! Ожидание около 3-5 минут!!!
```
sudo chmod +x deploy.sh
sudo ./deploy.sh
```

Ожидаем длинный вывод с перечисление запущенных контейнеров в конце:
```
╭─────────────────────────────────┬───────────────────────────────────────────┬─────────┬────────────────╮
│               Name              │                 Kind/Image                │  State  │ IPv4/6 Address │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-8-8-8-8            │ linux                                     │ running │ 172.20.20.8    │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-a-vni10101-1    │ linux                                     │ running │ 172.20.20.22   │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-a-vni10101-2    │ linux                                     │ running │ 172.20.20.14   │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-a-vni10102-1    │ linux                                     │ running │ 172.20.20.19   │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-a-vni10102-mlag │ linux                                     │ running │ 172.20.20.9    │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-b-vni20201-1    │ linux                                     │ running │ 172.20.20.2    │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-b-vni20201-2    │ linux                                     │ running │ 172.20.20.15   │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-b-vni20202-1    │ linux                                     │ running │ 172.20.20.20   │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-cl-b-vni20202-mh   │ linux                                     │ running │ 172.20.20.16   │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-edge-leaf-5        │ frrouting                                 │ running │ 172.20.20.3    │
│                                 │ lab/frr-edge:nat                          │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-internet           │ frrouting                                 │ running │ 172.20.20.4    │
│                                 │ quay.io/frrouting/frr:containerlab-10.7.1 │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-leaf-1             │ frrouting                                 │ running │ 172.20.20.17   │
│                                 │ quay.io/frrouting/frr:containerlab-10.7.1 │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-leaf-2             │ frrouting                                 │ running │ 172.20.20.21   │
│                                 │ quay.io/frrouting/frr:containerlab-10.7.1 │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-leaf-3             │ frrouting                                 │ running │ 172.20.20.10   │
│                                 │ quay.io/frrouting/frr:containerlab-10.7.1 │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-leaf-4             │ frrouting                                 │ running │ 172.20.20.18   │
│                                 │ quay.io/frrouting/frr:containerlab-10.7.1 │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-leaf-6             │ arista_ceos                               │ running │ 172.20.20.11   │
│                                 │ ceos:lab                                  │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-leaf-7             │ arista_ceos                               │ running │ 172.20.20.12   │
│                                 │ ceos:lab                                  │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-mgmt-pc            │ linux                                     │ running │ 172.20.20.5    │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-mgmt-sw            │ linux                                     │ running │ 172.20.20.6    │
│                                 │ ghcr.io/hellt/network-multitool:latest    │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-spine-1            │ frrouting                                 │ running │ 172.20.20.13   │
│                                 │ quay.io/frrouting/frr:containerlab-10.7.1 │         │ N/A            │
├─────────────────────────────────┼───────────────────────────────────────────┼─────────┼────────────────┤
│ clab-saas-dc-spine-2            │ frrouting                                 │ running │ 172.20.20.7    │
│                                 │ quay.io/frrouting/frr:containerlab-10.7.1 │         │ N/A            │
╰─────────────────────────────────┴───────────────────────────────────────────┴─────────┴────────────────╯
```

Можно подождать минуту. Arista EOS грузится дольше, чем FRR.

## Все контейнеры running?

Проверяем следующей командой:

```
RUNNING_COUNT=$(sudo docker ps --filter "name=clab-saas-dc-" --filter "status=running" --format '{{.Names}}' | wc -l) && \
sudo docker ps -a --filter "name=clab-saas-dc-" --format "table {{.Names}}\t{{.Status}}" && \
echo "" && \
if [ "$RUNNING_COUNT" -eq 21 ]; then \
    echo "✅ Успех: Все 21 контейнеров в статусе running."; \
else \
    echo "❌ Ошибка: Работает только $RUNNING_COUNT из 21 контейнеров!"; \
fi
```

Ожидаем:
```
✅ Успех: Все 21 контейнеров в статусе running.
```


##Сеть сошлась? Маршрутизация в норме?

Проверяем что BGP Established на всех spine и leaf (leaf-1 - 4, edge-leaf-5 - FRR, leaf-6 и leaf-7 - Arista EOS):
```
for node in $(sudo docker ps --format '{{.Names}}' | grep -E 'clab-saas-dc-(leaf-|spine-)'); do
    echo -e "\n=================== $node ==================="
    
    # Проверяем, Arista это (leaf-6, leaf-7) или FRR (все остальные)
    if [[ "$node" =~ "leaf-6" || "$node" =~ "leaf-7" ]]; then
        # Команды для Arista cEOS
        echo -e "enable\nshow bgp summary" | sudo docker exec -i "$node" Cli
    else
        # Команда для FRR
        sudo docker exec -i "$node" vtysh -c "show bgp summary"
    fi
done
```
Ожидаем везде Established на EOS и таймер Up/Down идет и есть pfxrcd и pfxsnt на FRR.

При необходимости таблицу маршрутизации можно посмотреть на любом маршрутизаторе:
Вот шпаргалка:
```sudo docker exec -it clab-saas-dc-leaf-1 vtysh```
И далее 
```
show bgp l2vpn evpn route type 2
show bgp l2vpn evpn route type 3
show bgp l2vpn evpn route type 5
```

Также можно проверить VNI:
```
show evpn vni
```

Таблицу изученных MAC адресов:
```
show evpn mac vni [VNI_ID]
```

## Клиентские хосты работают?

Проверяем, что все клиентские хосты запущены и видят свой шлюз по-умолчанию.
```
echo -e "\n=== Проверка связи хостов со шлюзами ===" && for c in cl-a-vni10101-1:10.10.10.1 cl-a-vni10101-2:10.10.10.1 cl-a-vni10102-1:10.10.20.1 cl-a-vni10102-mlag:10.10.20.1 cl-b-vni20201-1:10.10.10.1 cl-b-vni20201-2:10.10.10.1 cl-b-vni20202-1:10.10.20.1 cl-b-vni20202-mh:10.10.20.1 8-8-8-8:8.8.8.1 mgmt-pc:192.168.250.1; do name="clab-saas-dc-${c%%:*}"; gw="${c#*:}"; echo -n "• $name -> Пинг $gw: "; sudo docker exec -i "$name" ping -c 2 -W 2 "$gw" > /dev/null 2>&1 && echo "✅ OK" || echo "❌ FAIL"; done
```

## Клиенты изолированы друг от друга?

Нам необходимо следующее:
Попинговать машины клиента А в VNI 10101 между собой
Попинговать машины клиента Б в VNI 20201 между собой
Попинговать машины клиента А c машины в VNI 10101 в VNI 10102, так мы проверим L3VNI
Попинговать машины клиента Б с машины в VNI 20201 в VNI 20202, так мы проверим L3VNI
Попинговать с машины клиента А адрес любого клиента Б и наоборот. Увидеть, что ничего не пингуется.

```
echo -e "\n=== 1. Пинг машин клиента А в VNI 10101 между собой ===" && sudo docker exec -i clab-saas-dc-cl-a-vni10101-1 ping -c 2 -W 2 10.10.10.12 && echo -e "\n=== 2. Пинг машин клиента Б в VNI 20201 между собой ===" && sudo docker exec -i clab-saas-dc-cl-b-vni20201-1 ping -c 2 -W 2 10.10.10.14 && echo -e "\n=== 3. Проверка L3VNI (Клиент А): из VNI 10101 в VNI 10102 ===" && sudo docker exec -i clab-saas-dc-cl-a-vni10101-1 ping -c 2 -W 2 10.10.20.12 && echo -e "\n=== 4. Проверка L3VNI (Клиент Б): из VNI 20201 в VNI 20202 ===" && sudo docker exec -i clab-saas-dc-cl-b-vni20201-1 ping -c 2 -W 2 10.10.20.11 && echo -e "\n=== 5. Связь между клиентами (Изоляция Клиент А <-> Клиент Б) ===" && echo -n "А -> Б: " && (sudo docker exec -i clab-saas-dc-cl-a-vni10101-1 ping -c 2 -W 2 10.10.10.13 > /dev/null 2>&1 && echo "❌ ОШИБКА: Пинг прошел!" || echo "✅ УСПЕХ: Ничего не пингуется (Сети изолированы)") && echo -n "Б -> А: " && (sudo docker exec -i clab-saas-dc-cl-b-vni20201-1 ping -c 2 -W 2 10.10.10.11 > /dev/null 2>&1 && echo "❌ ОШИБКА: Пинг прошел!" || echo "✅ УСПЕХ: Ничего не пингуется (Сети изолированы)")
```

Ожидаем связь между машинами, кроме последних двух проверок, где клиенты не должны видеть друг друга.


## Что с EVPN MH на Leaf-1 и leaf-2?

Проверяем что на leaf-1 и leaf-2 успешно работают eth4 в LACP (интерфейс bond20202):
```
echo "=== Статус LACP Bond ===" && for leaf in leaf-1 leaf-2; do echo -e "\n[$leaf]:"; sudo docker exec -i clab-saas-dc-$leaf cat /proc/net/bonding/bond20202 | grep -E 'Aggregation|Actor System ID|Partner System ID|Slave Interface'; done
```
Ожидаем:
```
=== Статус LACP Bond ===

[leaf-1]:
Slave Interface: eth4

[leaf-2]:
Slave Interface: eth4
```

Затем смотрим статус ES, заодно видим кто стал DF:
```
echo "=== EVPN Ethernet Segments ===" && for leaf in leaf-1 leaf-2; do echo -e "\n=================== $leaf ==================="; sudo docker exec -i clab-saas-dc-$leaf vtysh -c "show evpn es detail"; done
```

Ожидаем:
```
=== EVPN Ethernet Segments ===

=================== leaf-1 ===================
ESI: 03:02:00:00:02:02:02:00:4e:ea
 Type: Local,Remote
 Interface: bond20202
 State: up
 Bridge port: yes
 Ready for BGP: yes
 VNI Count: 1
 MAC Count: 1
 DF status: df
 DF preference: 32767
 Nexthop group: 536870913
 VTEPs:
     10.255.0.12 df_alg: preference df_pref: 32767 nh: 268435458


=================== leaf-2 ===================
ESI: 03:02:00:00:02:02:02:00:4e:ea
 Type: Local,Remote
 Interface: bond20202
 State: up
 Bridge port: yes
 Ready for BGP: yes
 VNI Count: 1
 MAC Count: 1
 DF status: non-df
 DF preference: 32767
 Nexthop group: 536870913
 VTEPs:
     10.255.0.11 df_alg: preference df_pref: 32767 nh: 268435458

```

Смотрим Type-4 маршруты на Leaf-1 и leaf-2:
```
echo "=== Маршруты EVPN MH ===" && for leaf in leaf-1 leaf-2; do echo -e "\n=================== $leaf ==================="; sudo docker exec -i clab-saas-dc-$leaf vtysh -c "show bgp l2vpn evpn route type es"; done
```

Ожидаем маршруты с нашим ESI, где next-hop это VTEP 10.255.0.11 на leaf-2 или 10.255.0.12 на leaf-1


## Что с MLAG на Leaf-6 и Leaf-7?

Проверяем, что на leaf-6 и leaf-7 с MLAG все хорошо.
```
for leaf in leaf-6 leaf-7; do echo -e "\n=================== $leaf (MLAG Summary) ==================="; echo -e "enable\nshow mlag" | sudo docker exec -i clab-saas-dc-$leaf Cli; done
```

Ожидаем в строке MLAG Status для каждого leaf:
```
MLAG Status:
state                              :              Active
negotiation status                 :           Connected
peer-link status                   :                  Up
local-int status                   :                  Up
```

Можно проверить Po интерфейсы в составе MLAG 101:
```
for leaf in leaf-6 leaf-7; do echo -e "\n=================== $leaf (MLAG Detail) ==================="; echo -e "enable\nshow mlag interfaces" | sudo docker exec -i clab-saas-dc-$leaf Cli; done
```
Ожидаем на обоих leaf state - active-full.

Имитируем аварию, чтобы проверить, что клиент не теряет связь при обрыве одного линка:
```
echo "=== 1. Запуск частого пинга во временный файл ===" && \
sudo docker exec -d clab-saas-dc-cl-a-vni10102-mlag sh -c "ping -c 30 -i 0.2 10.10.20.1 > /tmp/mlag_test.log 2>&1" && \
echo "Пинг запущен (результаты пишутся в /tmp/mlag_test.log)..." && \
sleep 1 && \
echo -e "\n=== 2. АВАРИЯ: Отключаем порт Ethernet5 на leaf-6 ===" && \
echo -e "enable\nconfigure\ninterface ethernet 5\nshutdown" | sudo docker exec -i clab-saas-dc-leaf-6 Cli > /dev/null && \
echo "Порт Eth5 на leaf-6 переведен в SHUTDOWN. Сходимость MLAG..." && \
sleep 6 && \
echo -e "\n=== 3. РЕЗУЛЬТАТЫ (Статистика пинга с хоста) ===" && \
sudo docker exec -i clab-saas-dc-cl-a-vni10102-mlag cat /tmp/mlag_test.log && \
echo -e "\n=== 4. ВОССТАНОВЛЕНИЕ: Включаем порт обратно ===" && \
echo -e "enable\nconfigure\ninterface ethernet 5\nno shutdown" | sudo docker exec -i clab-saas-dc-leaf-6 Cli > /dev/null && \
echo "Порт Eth5 на leaf-6 восстановлен в исходное состояние."
```

Ожидаем восстановление связи после отключения порта или вообще ни одного потерянного пакета.


## Проверка QOS

Пингуем что-нибудь удаленное с машины из приоритетного сегмента и смотрим счетчики на leaf в сторону spine, например.
```
echo "=== ТЕСТ QoS: Пинг между узлами из приоритетного сегмента ===" && \
echo "--- ДО ТЕСТА  ---" && \
for int in eth1 eth2; do echo "[$int]:"; sudo docker exec -i clab-saas-dc-leaf-4 tc -s class show dev "$int" | grep -A 2 "class htb 1:20"; done && \
echo -e "\n🔥 Отправляем 50 пакетов на удаленный хост 10.10.10.11..." && \
sudo docker exec -i clab-saas-dc-cl-a-vni10102-1 ping -c 50 -i 0.05 10.10.10.11 > /dev/null && \
echo -e "\n--- ПОСЛЕ ТЕСТА ---" && \
for int in eth1 eth2; do echo "[$int]:"; sudo docker exec -i clab-saas-dc-leaf-4 tc -s class show dev "$int" | grep -A 2 "class htb 1:20"; done
```

Ожидаем изменения кол-ва пакетов в счетчике класса 1:20 на eth-1 или eth-2. Почему на одном? Потому что ECMP работает per-flow, а не per-packet:).
Смотреть на Sent XXXX bytes XX pkt.

```
--- ПОСЛЕ ТЕСТА ---
[eth1]:
class htb 1:20 parent 1:1 leaf 120: prio 1 rate 25Mbit ceil 100Mbit burst 1600b cburst 1600b
Sent 8584 bytes 58 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
[eth2]:
class htb 1:20 parent 1:1 leaf 120: prio 1 rate 25Mbit ceil 100Mbit burst 1600b cburst 1600b
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

```

Нейросеть подсказала, что можно сделать через iperf и тогда это будет честнее так как будет действительно несколько потоков:
Также заметил, что бывает, что docker "откидывает" линки от хостов, если они долго не генерируют трафик. Перед тестом лучше повторно сделать пинг со всех хостов на шлюз, чтобы "разбудить" ARP таблицы.
```
echo -e "\n=== Проверка связи хостов со шлюзами ===" && for c in cl-a-vni10101-1:10.10.10.1 cl-a-vni10101-2:10.10.10.1 cl-a-vni10102-1:10.10.20.1 cl-a-vni10102-mlag:10.10.20.1 cl-b-vni20201-1:10.10.10.1 cl-b-vni20201-2:10.10.10.1 cl-b-vni20202-1:10.10.20.1 cl-b-vni20202-mh:10.10.20.1 8-8-8-8:8.8.8.1 mgmt-pc:192.168.250.1; do name="clab-saas-dc-${c%%:*}"; gw="${c#*:}"; echo -n "• $name -> Пинг $gw: "; sudo docker exec -i "$name" ping -c 2 -W 2 "$gw" > /dev/null 2>&1 && echo "✅ OK" || echo "❌ FAIL"; done
```
Затем проверем с помощью Iperf.
```
sudo docker exec -i clab-saas-dc-cl-a-vni10101-1 pkill iperf3 || true
sudo docker exec -d clab-saas-dc-cl-a-vni10101-1 iperf3 -s
sleep 1
echo "🔥 Запуск iperf3: 50 параллельных UDP потоков для проверки ECMP..." && \
sudo docker exec -i clab-saas-dc-cl-a-vni10102-1 iperf3 -c 10.10.10.11 -u -b 1M -P 50 -t 3 > /dev/null && \
echo -e "\n=== Проверка распределения трафика (Класс 1:20 / EF) ===" && \
for int in eth1 eth2; do echo "[$int]:"; sudo docker exec -i clab-saas-dc-leaf-4 tc -s class show dev "$int" | grep -A 2 "class htb 1:20"; done
```

Ожидаем изменения кол-ва пакетов в счетчике класса 1:20 на eth-1 и(!!!) eth-2. Смотреть на Sent XXXX bytes XX pkt.

## Graceful shutdown leaf-1 (EVPN-MH)

Для теста запускаем пинг с хоста cl-b-vni20202-mh на cl-b-vni20201-1 т.е. с 10.10.20.50 на 10.10.10.13. Leaf-1 сообщит всем, что он отключается, трафик перейдет на leaf-2 без потерь.
```
echo "=== 1. ЗАПУСК ТЕСТОВОГО ТРАФИКА С ХОСТА EVPN MH ===" && \
sudo docker exec -d clab-saas-dc-cl-b-vni20202-mh sh -c "ping -c 40 -i 0.2 10.10.10.13 > /tmp/gshut_mh_test.log 2>&1" && \
echo "Пинг через L3VNI запущен (40 пакетов с интервалом 0.2 сек)..." && \
sleep 1 && \
echo -e "\n=== 2. GRACEFUL SHUTDOWN: Плавно выводим leaf-1 из BGP-фабрики ===" && \
sudo docker exec -i clab-saas-dc-leaf-1 vtysh \
  -c "configure terminal" \
  -c "router bgp 65000" \
  -c "bgp graceful-shutdown" \
  -c "end" && \
echo "Команда bgp graceful-shutdown активирована на leaf-1. Ждем сходимости..." && \
sleep 8 && \
echo -e "\n=== 3. РЕЗУЛЬТАТЫ (Статистика пинга без потери пакетов) ===" && \
sudo docker exec -i clab-saas-dc-cl-b-vni20202-mh cat /tmp/gshut_mh_test.log && \
echo -e "\n=== 4. ВОССТАНОВЛЕНИЕ: Возвращаем leaf-1 в строй ===" && \
sudo docker exec -i clab-saas-dc-leaf-1 vtysh \
  -c "configure terminal" \
  -c "router bgp 65000" \
  -c "no bgp graceful-shutdown" \
  -c "end" && \
echo "Leaf-1 снова в работе."
```

Часто ловил баг, что после no bgp graceful-shutdown leaf просто не хочет рассылать всем остальным, что теперь через него можно слать трафик. Поэтому перед следующей проверкой лучше сделать так:
```
sudo containerlab destroy -t saas-dc.clab.yml --node-filter leaf-1
sudo containerlab deploy -t saas-dc.clab.yml
```

## Остановка и очистка
```
clab destroy -c
```