# Redirector
Redirects all HTTP requests to HTTPS. Useful to redirect HTTP requests coming into the Amazon ELB to the corresponding HTTPS url.

## Environment Variables

 * **PROXY_PROTOCOL=false** - Enable proxy protocol on the nginx vhost which is needed when using the AWS ELB in TCP mode for websocket support.

## Command Line Usage

```
Usage: docker run -p 80:80 meltwater/redirector:latest [options]...

Redirects all HTTP requests to HTTPS

Options:
  -h, --help        show this help message and exit
  --proxy-protocol  Enable proxy protocol on nginx [default: False]
  -v, --verbose     Increase logging verbosity
```

## Deployment

### Systemd

Create a [Systemd unit](http://www.freedesktop.org/software/systemd/man/systemd.unit.html) file 
in **/etc/systemd/system/redirector.service** with contents like below. 

```
[Unit]
Description=Redirects HTTP requests to HTTPS
After=docker.service
Requires=docker.service

[Install]
WantedBy=multi-user.target

[Service]
Environment=IMAGE=meltwater/redirector:latest NAME=redirector

# Allow docker pull to take some time
TimeoutStartSec=600

# Restart on failures
KillMode=none
Restart=always
RestartSec=15

ExecStartPre=-/usr/bin/docker kill $NAME
ExecStartPre=-/usr/bin/docker rm $NAME
ExecStartPre=-/bin/sh -c 'if ! docker images | tr -s " " : | grep "^${IMAGE}:"; then docker pull "${IMAGE}"; fi'
ExecStart=/usr/bin/docker run -p 80:80 $IMAGE
ExecStop=/usr/bin/docker stop $NAME
```

### Puppet Hiera

Using the [garethr-docker](https://github.com/garethr/garethr-docker) module

```
classes:
  - docker::run_instance

docker::run_instance:
  'redirector':
    image: 'meltwater/redirector:latest'
    ports:
      - '80:80'
```
