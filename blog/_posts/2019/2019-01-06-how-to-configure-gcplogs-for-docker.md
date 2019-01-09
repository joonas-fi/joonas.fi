---
layout:     post
title:      'How to configure gcplogs (Google Cloud Logging) for Docker'
date:       2019-01-06 12:45:00
tags:       ['programming']
---

.. from a perspective where you are not running your VM on a Google datacenter - if you
would be, then this would be a bit simpler because the logging driver
[autodiscovers](https://cloud.google.com/compute/docs/storing-retrieving-metadata)
credentials and more options automatically for you.

I wrote this because there were bits of advice scattered around, but no single "do this
to get it working" anywhere.

Terms:

- [gcplogs](https://docs.docker.com/config/containers/logging/gcplogs/) - the built-in
  plugin of Docker that sends log messages to Stackdriver Logging
- [Stackdriver Logging](https://cloud.google.com/logging/docs/) - the new name for Google Cloud (Platform) Logging ("gcp logs").


Why Stackdriver Logging?
------------------------

[Practically free](https://cloud.google.com/stackdriver/pricing) (free quota of 50 GB /
month), centralized logging.


Choose a project in Google Cloud Platform console
-------------------------------------------------

Select your project (or create a new one).

I chose `function61-logs` as my project name.


Create service account credentials
----------------------------------

For this project, create a new service account:

- Service account name = `docker-host` (you can choose whatever you want)
- Roles =
	* `Monitoring / Monitoring Metric Writer` and
	* `Logging / Logs Writer`

Download access key as a JSON file. You need to transfer this to each of your server.


Configure servers for logging
-----------------------------

You need to do this on each of your servers.

Place the JSON credential file at `/etc/docker/googlecloud-serviceaccount.json`.

Edit `/etc/docker/daemon.json` to contain:

	{
	  "log-driver": "gcplogs",
	  "log-opts": {
	    "gcp-project": "function61-logs",
	    "mode": "non-blocking",
	    "max-buffer-size": "2m"
	  }
	}

You should use
[non-blocking delivery mode](https://docs.docker.com/config/containers/logging/configure/#configure-the-delivery-mode-of-log-messages-from-container-to-log-driver).

Rant:

> GCP logging code has such a user hostility, that we can't just configure a log option with
> the credentials, but instead we need to set an environment variable to the Docker daemon
> that contains the path to the JSON credential file.. this is so preposterous because if
> we need to customize ENV vars of the Docker daemon, these instructions are totally
> dependent on the server's init system AND what name the service operates under... WTF
> why couldn't you just let us configure this as a logger option, since the facilities
> are already there!!!

We'll use a
[systemd drop-in](https://coreos.com/os/docs/latest/using-systemd-drop-in-units.html) to
add the ENV:

	$ mkdir -p /etc/systemd/system/docker.service.d
	$ echo -e "[Service]\nEnvironment=GOOGLE_APPLICATION_CREDENTIALS=/etc/docker/googlecloud-serviceaccount.json\n" > /etc/systemd/system/docker.service.d/gcplogging.conf

After editing service definition files, you should probably run:

	$ systemctl daemon-reload


Restart Docker
--------------

WARNING: this will restart all your containers.

	$ systemctl restart docker

Status should tell you that the drop-in is enabled:

	$ systemctl status docker
	● docker.service - Docker Application Container Engine
	   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
	  Drop-In: /etc/systemd/system/docker.service.d
	           └─gcplogging.conf
	   Active: active (running) since Sun 2019-01-06 13:21:07 CET; 5min ago
	     Docs: https://docs.docker.com
	 Main PID: 10637 (dockerd)
	    Tasks: 18
	   CGroup: /system.slice/docker.service
	           └─10637 /usr/bin/dockerd -H unix://

You should also see this:

	$ docker info
	Logging Driver: gcplogs

Your containers' logs should now appear in "Stackdriver Logging" at Google Cloud console.


No severity levels or hostname
------------------------------

The driver [doesn't support](https://github.com/moby/moby/issues/22736)
`log message severity` at all. Every message shows up in the console as "huh, dunno" type.

Also the hostname does not get appended to the log message metadata. It probably would be
if we were running on Google Cloud Platform due to its autodiscovery magic. But the
configuration suggests doing this:

```
$ docker run --log-driver=gcplogs \
    --log-opt gcp-project=test-project
    --log-opt gcp-meta-zone=west1 \
    --log-opt gcp-meta-name=`hostname` \
    your/application
```

The above of course applies to when launching containers manually, but who the hell does
that in a production environment and does not use an orchestrator? And who wants to
configure custom log driver for each container and not use the same logger for all containers?

This means that we should put the hostname to Docker's `daemon.json`, which means that we
should generate it programmatically generate it for each host.

I'm running CoreOS and the base installation is customized via
[CoreOS Ignition](https://coreos.com/ignition/docs/latest/) and I actually use it to
generate an immutable base image from which several VMs are launched - so I cannot put the
hostname into the ignition file, so I would have to build the
"modify daemon.json dynamically" step at my "bootstrap cluster node" level.

All this to configure a freaking user hostile logging plugin that easily could've let the
user configure this by implementing recognizing special literal `$hostname` value for
`gcp-meta-name` and fetch the hostname dynamically!


In summary
----------

It looks like running containers outside of Google's cloud was an afterthought
to the developers of `gcplogs` logging driver.

It's a shame, because little more work could've brought the experience from "meh" to "awesome!".
