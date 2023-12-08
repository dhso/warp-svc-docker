FROM ubuntu:22.04
ENV WARP_LICENSE=
ENV TEAMS_ENROLL_TOKEN=
ENV FAMILIES_MODE=off
EXPOSE 1080/tcp
RUN apt update && \
  apt install curl gpg socat wget -y && \
  curl https://pkg.cloudflareclient.com/pubkey.gpg | \
  gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main" | \
  tee /etc/apt/sources.list.d/cloudflare-client.list && \
  apt update && \
  apt install cloudflare-warp -y && \
  rm -rf /var/lib/apt/lists/*
COPY --chmod=755 entrypoint.sh entrypoint.sh
COPY --chmod=755 yxip.sh /usr/local/bin/yxip.sh
COPY --chmod=755 yxwarp /usr/local/bin/yxwarp
COPY --chmod=755 nf /usr/local/bin/nf
VOLUME ["/var/lib/cloudflare-warp"]
WORKDIR /var/lib/cloudflare-warp
CMD ["/bin/bash", "/entrypoint.sh"]