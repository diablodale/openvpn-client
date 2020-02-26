FROM alpine
MAINTAINER Dale Phurrough <dale@hidale.com>

# Install openvpn
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl ip6tables iptables openvpn \
                shadow tini ca-certificates unbound && \
    addgroup -S vpn && \
    rm -rf /tmp/*
COPY openvpn.sh /usr/bin/

# Install unbound
COPY unbound.conf /etc/unbound/unbound.conf
ADD resolv.unbound /etc/resolv.unbound
RUN chmod -R u=rwX,go=rX /etc/unbound/ && \
    ln -s ../../usr/share/dnssec-root/trusted-key.key /etc/unbound/root.key && \
    chmod 444 /etc/resolv.unbound

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

VOLUME ["/vpn"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/openvpn.sh"]