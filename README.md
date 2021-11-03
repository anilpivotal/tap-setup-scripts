# This is work in progress on Beta 3, build 7

## Setting up Tanzu Application Platform on a local machine

These are scripts I've used to set up beta versions of
Tanzu Application Platform (TAP) on a VM using
[Kind](https://kind.sigs.k8s.io/) and on GKE.
It may also work (but is less tested) on TCE, TKG and EKS.

It is known to work with DockerHub, Harbor and GCR for the container
registry.

From the pre-requisites in the
[the official documentation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-overview.html).:

> To deploy all Tanzu Application Platform packages your cluster must
> have at least 8 GB of RAM across all nodes available to Tanzu
> Application Platform. At least 8 CPUs for i9 or equivalent or 12 CPUs
> for i7 or equivalent must be available to Tanzu Application Platform
> components. VMware recommends that at least 16 GB of RAM is available
> to build and deploy applications, including for Kind and Minikube.

There are three scripts here:

* `install-prereqs.sh`
* `kind-with-registry.sh`
* `setup-tap.sh`

The first, `install-prereqs.sh`, installs the necessary CLI tools on
64-bit AMD/Intel Ubuntu-like Linux systems (including WSL under Windows).
These tools are:

* `docker`, `kubectl` and `kind`.
* The tools from [carvel.dev](https://carvel.dev) (`ytt`, `kbld`, `kapp`,
  `imgpkg` and `vendir`.
* The `kp` [kpack CLI](https://github.com/vmware-tanzu/kpack-cli).
* The `kn` [Knative CLI](https://github.com/knative/client).
* The `tanzu` CLI from the [Tanzu Network](https://network.tanzu.vmware.com/products/tanzu-application-platform/).

The second sets up a Kind cluster (named `tap`) which has port forwarding
to ports 80, 443 and 53.
The DNS (port 53) forwarding is probably not necessary but could be used
to hook into the cluster DNS.
The HTTP/S ports will expose applications deployed on TAP via `*.vcap.me`
URLs (all lookups of `vcap.me` addresses resolve to 127.0.0.1).

You will also need a login to the Tanzu Network and access to a Docker
registry (e.g. DockerHub) to which you can push container images.

The script will prompt you for Tanzu Network and registry credentials, but
you can also set these as environment variables and it will pick them
up automatically.
If set, values will be taken from `TN_USERNAME` and `TN_PASSWORD` for
the Tanzu Network and `REGISTRY`, `REG_USERNAME` and `REG_PASSWORD` for
the registry.

By default, the script assumes an installation on a local cluster,
such as Kind or Minikub, where services will be accessed via the
`localhost` address.
However, it can also be used for an installation on to a full,
externally-accessible cluster.
In order to enable this you should set the `DOMAIN` environment
variable (or supply a value when prompted) to something other than
the default of `vcap.me`.

After the setup script completes you should have a fully functioning TAP
installation, ready to build and run applications.

If the installation fails at any point it should be safe to re-run the setup
script.
In particular, the initial installation of the Tanzu Build Service component
may time out, although it is likely to complete successfully in the background.

#### Use with DockerHub

Unlike other container registries, DockerHub does not support
hierarchical registry paths.
This means that the initial registry path that you specify, for
example `some-user/tap` will only be the path for the Tanzu Build
Service images.
Any new application created with the build service will appear
as a new registry beneath your user account, for example,
`some-user/my-new-app`.

#### Use with Google Container Registry (GCR)

If you intend to use the setup script with a `gcr.io` registry then
you will need an JSON-formatted access key and must use `_json_key`
as the username.
The easiest way to provide the information to the setup script
is to export environment variables, for example, as follows:

```bash
export REGISTRY=gcr.io/my-project-name/tap
export REG_USERNAME=_json_key
export REG_PASSWORD="$(cat gcr-access-key.json)"
```

### Using TAP

Port forwarding will have been set up so that the Application Accelerator should
be accessible on http://localhost:8877 and App Live View on http://localhost:5112.

The TAP components are configured to work with applications deployed primarily in
the `default` namespace.

You should be able to follow the
[Getting Started guide](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/0.3/tap-0-3/GUID-getting-started.html)
to deploy your first application to the platform.

