# warp-svc
Cloudflare WARP client as a socks5 server in docker

This dockerfile will create a docker image with official Cloudflare WARP client for linux and provides a socks5 proxy to use in other compaliant applications either in your local machine or by other docker containers in a docker compose or Kubernetes.

The official Cloudflare WARP client for Linux only listens on localhost for the socks proxy so you cannot use it in a docker container which need to bind on 0.0.0.0

## Features
* Register a new Cloudflare WARP account
* Configurable "families mode"
* Subscribe to Cloudflare WARP+
* Subscribe to Cloudflare Team

## How to use
The socks proxy in exposed on port `1080`

You can use these environment variables:
* `FAMILIES_MODE`: Use one of `off`, `malware` and `full` values. (Default: `off`)
* `WARP_LICENSE`: Put your WARP+ licesne. (You can get a free WARP+ license from this telegram bot: https://t.me/generatewarpplusbot)
* `TEAMS_ENROLL_TOKEN`: Put your Team enroll token. (You can get token from this steps)
```
1. visit: https://<your_domain>.cloudflareaccess.com/warp

2. On the Success page, right-click and select View Page Source.

Find the HTML metadata tag that contains the token. For example, <meta http-equiv="refresh" content"=0;url=com.cloudflare.warp://acmecorp.cloudflareaccess.com/auth?token=yeooilknmasdlfnlnsadfojDSFJndf_kjnasdf..." />

3. Copy the URL field: com.cloudflare.warp://<your-team-name>.cloudflareaccess.com/auth?token=<your-token>
OR
content=document.querySelector("meta[http-equiv='refresh']").content.split("=");
console.log(content[1]+"="+content[2])
```

You should mount `/var/lib/cloudflare-warp` directory of the container to your host to make you WARP account persistant. Notice that each WARP+ license is working only on 4 device so persisting the configuration is important!

### Using as a local proxy with Docker
```
docker run -d --name=warp --hostname=warp -e FAMILIES_MODE=full -e WARP_LICENSE=xxxxxxxx-xxxxxxxx-xxxxxxxx -p 127.0.0.1:1080:1080 -v ${PWD}/warp:/var/lib/cloudflare-warp dhso/warp-svc:latest
```
You can verify warp by visiting this url:
```
curl --socks5 127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace

warp=on
```
You can also use `warp-cli` command to control your connection:
```
docker exec warp warp-cli --accept-tos status

Status update: Connected
Success
```
### Using as a proxy for other containers with docker-compose

```
version: "3"
services:
  warp:
    image: dhso/warp-svc:latest
    expose:
    - 1080
    restart: always
    hostname: my_hostname
    environment:
      WARP_LICENSE: xxxxxxxx-xxxxxxxx-xxxxxxxx
      FAMILIES_MODE: off
    volumes:
    - ./warp:/var/lib/cloudflare-warp
  app:
    image: <app-image>
    depends_on:
    - warp
    environment:
      proxy: warp:1080
```

# build
```
docker build -f $(pwd)/Dockerfile -t dhso/warp-svc:latest $(pwd)
```

# secret command
```
yxip.sh
```