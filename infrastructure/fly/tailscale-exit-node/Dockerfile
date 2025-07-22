FROM alpine:latest
# alpine:3.19 links iptables to iptables-nft https://gitlab.alpinelinux.org/alpine/aports/-/commit/f87a191922955bcf5c5f3fc66a425263a4588d48.
# iptables-nft requires kernel support for nft, which is currently not available in Fly.io,
# so we remove the links and ensure that the iptables-legacy version is used.
RUN apk update && apk add ca-certificates iptables iptables-legacy ip6tables  \
    && rm -rf /var/cache/apk/* \
    && rm -rf /sbin/iptables && ln -s /sbin/iptables-legacy /sbin/iptables  \
    && rm -rf /sbin/ip6tables && ln -s /sbin/ip6tables-legacy /sbin/ip6tables


# creating directories for tailscale
RUN mkdir -p /var/run/tailscale
RUN mkdir -p /var/cache/tailscale
RUN mkdir -p /var/lib/tailscale

# Copy Tailscale binaries
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscaled /app/tailscaled
COPY --from=docker.io/tailscale/tailscale:stable /usr/local/bin/tailscale /app/tailscale

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Run on container startup.
USER root
ENTRYPOINT "/app/entrypoint.sh"
CMD ["/app/entrypoint.sh"]
