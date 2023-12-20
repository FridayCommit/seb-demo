# seb-demo

A small project for bootstrapping a local cluster with some baseline resources for local development.

Resources:

* [Crossplane documentation](https://docs.crossplane.io/)
* [Crossplane Terraform provider](https://github.com/upbound/provider-terraform)
* [GitHub Terraform provider](https://registry.terraform.io/providers/integrations/github/latest/docs)
* [Demo (video) - GitHub repository creation with the Cossplane Terraform provider](https://youtu.be/_c58FpT2IYI?si=0CL7v6EVtup3Il6q)

## Prerequisites

You need to install the following tools:

* [GitHub CLI](https://github.com/cli/cli)
* [``kubectl``](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [`kustomize`](https://kubectl.docs.kubernetes.io/installation/kustomize/)
* [`kubectx` + `kubens`](https://github.com/ahmetb/kubectx)
* [`kind`](https://kubernetes.io/docs/tasks/tools/#kind)

In `WSL` or linux like shell, you can run the following to install everything:

```sh
sh <(curl -L https://nixos.org/nix/install) --daemon
nix-env -iA nixpkgs.gh nixpkgs.kubectl nixpkgs.kubectx
go install sigs.k8s.io/kind@latest
go install sigs.k8s.io/kustomize/kustomize/v5@latest
```

Not required, but a great tool to use in [``OpenLens``](https://github.com/MuhammedKalkan/OpenLens) (there is a payed version of `Lens` as well, but that costs money). It's basically an Kubernetes IDE, which is a godsend when working with Kubernetes. Personally I installed it with `Scoop`, but there are other options listed [here](https://github.com/MuhammedKalkan/OpenLens#installation)

## Bootstrap Cluster

### Create Cluster

First we need to create the `Kind` cluster:

```sh
kind create cluster
```

This command will create a new `Kind` cluster and add creds to your [``kubeconfig``](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), which will make subsequent calls with `kubectl` use the ``Kind`` cluster. You can verify this by running `kubectx` in your terminal and making sure that the context you are using is called `kind-kind`. If you run `kubens` the number of `namespaces` in the cluster shouldn't be more than like 5. If you have ``openlens`` you can also use that while using the local cluster.

### Setup ArgoCD

ArgoCD is located under ``k8s/argocd``, and can be setup by running `kubectl apply -k k8s/argocd`. With lens you can use [port-forwarding](https://docs.k8slens.dev/cluster/use-port-forwarding/) to access it in the browser.

### Build k8s config

You can run the following commands to make sure that it all looks correct. The environmental variables and `envsubst` will inject secrets to [`github-creds.yaml`](/k8s/crossplane-providers/github/github-creds.yaml) without committing any real secrets to code.

```sh
export GH_TOKEN=$(gh auth token)
kustomize build --enable-helm k8s | envsubst
```

You can verfiy that the secrets are indeed set by running:

```sh
kustomize build --enable-helm k8s | envsubst | yq 'select(.kind == "Secret")'
```

### Applying k8s config

You hav 2 choices here, either run `kubectl` as described below, or proceed by using ArgoCD and the bootstrapped applications. Do note that if you use the ArgoCD applications, the secrets will be dumy values that you will have to overwrite yourself (eg [`github-creds.yaml`](/k8s/crossplane-system/crossplane-providers/github/github-creds.yaml) is using `${GH_TOKEN}`, which in the ``kubectl`` solution can be overwritten with [`envsubst`](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)).

For actually applying it all you can run the command below, but do make sure first you are actually connected to the local cluster, and not an actual AKS cluster. Do note that it will take a couple of repeated invokations before it all is ready. This is because there are CRD:s that takes some time to be installed correctly. Continue running the commads a few times over a minute or so and it should all be working:

```sh
kustomize build --enable-helm k8s | envsubst | kubectl apply -f -
```
