FROM ubuntu:22.04
ENV WARP_LICENSE=
ENV TEAMS_ENROLL_TOKEN=
ENV FAMILIES_MODE=off
ENV REOPTIMIZE_INTERVAL=-1
# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

RUN apt update \
  && apt install curl gpg socat wget -y \
  && wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py -O /usr/local/bin/systemctl \
  && curl -fsSLO "$SUPERCRONIC_URL" \
  && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
  && chmod +x "$SUPERCRONIC" \
  && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
  && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic \
  && curl https://pkg.cloudflareclient.com/pubkey.gpg | \
    gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main" | \
    tee /etc/apt/sources.list.d/cloudflare-client.list \
  && apt update \
  && apt install cloudflare-warp -y \
  && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 entrypoint.sh entrypoint.sh
COPY --chmod=755 yxip.sh /usr/local/bin/yxip.sh
COPY --chmod=755 yxwarp /usr/local/bin/yxwarp
COPY --chmod=755 nf /usr/local/bin/nf
COPY --chmod=755 reoptimize.sh /usr/local/bin/reoptimize.sh

VOLUME ["/var/lib/cloudflare-warp"]

WORKDIR /var/lib/cloudflare-warp
EXPOSE 1080/tcp

CMD ["/bin/bash", "/entrypoint.sh"]