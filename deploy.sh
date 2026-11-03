#!/usr/bin/env bash
set -euo pipefail

# Пути считаются от расположения скрипта,
# а не от текущего рабочего каталога.
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Здесь укажи фактическое имя YAML лабораторной.
TOPOLOGY="$ROOT_DIR/saas-dc.clab.yml"

command -v docker >/dev/null || {
    echo "Ошибка: Docker не установлен" >&2
    exit 1
}

command -v containerlab >/dev/null || {
    echo "Ошибка: containerlab не установлен" >&2
    exit 1
}

[[ -f "$TOPOLOGY" ]] || {
    echo "Ошибка: не найдена топология $TOPOLOGY" >&2
    exit 1
}

echo "=== Импорт контейнера Arista EOS Долго!!! Несколько минут!!! Не зависло!!!==="

docker import "$ROOT_DIR/images/ceos/cEOS64-lab-4.37.0F.tar.xz" ceos:lab

echo "=== Сборка образа edge-leaf с поддержкой NAT ==="

docker build \
    --tag lab/frr-edge:nat \
    "$ROOT_DIR/images/edge-leaf"

echo "=== Развёртывание лабораторной ==="

exec containerlab deploy \
    --topo "$TOPOLOGY" \
    "$@"
