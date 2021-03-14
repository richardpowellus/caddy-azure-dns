FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/azure \
    --with github.com/greenpau/caddy-auth-portal

FROM caddy

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
