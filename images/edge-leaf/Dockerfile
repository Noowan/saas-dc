ARG FRR_IMAGE=quay.io/frrouting/frr:containerlab-10.7.1

FROM alpine:3.22 AS tools
RUN apk add --no-cache apk-tools-static

FROM ${FRR_IMAGE}

USER root

COPY --from=tools /sbin/apk.static /tmp/apk.static
COPY --from=tools /etc/apk/keys/ /tmp/apk-keys/

RUN printf '%s\n' \
      'https://dl-cdn.alpinelinux.org/alpine/v3.22/main' \
      > /tmp/apk.repositories \
    && /tmp/apk.static \
         --keys-dir /tmp/apk-keys \
         --repositories-file /tmp/apk.repositories \
         --no-cache \
         add iptables iproute2 \
    && rm -rf /tmp/apk.static /tmp/apk-keys /tmp/apk.repositories
