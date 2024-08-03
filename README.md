# Kubeconfig Module

The purpose of this module is to render/write kubeconfig files locally or to a remote resource by _patching_ or _replacing_ the existing kubeconfig, if present. If `path` does not point to a valid kubeconfig file, a new config is created.

All fields present in the `kubeconfig.v1` spec are supported:
https://kubernetes.io/docs/reference/config-api/kubeconfig.v1

This module does not depend on any external providers.

## Usage

### Example 1 - Local usage

Add a set of new cluster credentials to your local `~/.kube/config` file using `patch` and `write=true`:

```hcl
module "kubeconfig" {
  source = "patrikkj/kubeconfig/k8s"
  path   = "~/.kube/config"
  write  = true

  current-context = "my-cluster-name"
  patch = {
    clusters = {
      "my-cluster-name" = {
        certificate-authority-data = base64encode("...")
        server                     = "https://0.0.0.0:6443"
      }
    }
    contexts = {
      "my-context-name" = {
        cluster = "my-cluster-name"
        user    = "my-user-name"
      }
    }
    users = {
      "my-user-name" = {
        client-certificate-data = base64encode("...")
        client-key-data         = base64encode("...")
      }
    }
  }
}
```

### Example 2 - Remote usage

Create/replace a kubeconfig file on a remote resource, e.g. when adding a worker node to a `k3s` cluster.

```hcl
locals {
  cluster_name           = "my-cluster"
  endpoint               = "192.168.10.101"
  cluster_ca_certificate = base64encode("...")
  client_certificate     = base64encode("...")
  client_key             = base64encode("...")
}

module "kubeconfig" {
  source = "patrikkj/kubeconfig/k8s"
  write  = false

  current-context = local.cluster_name
  replace = {
    clusters = {
      (local.cluster_name) = {
        certificate-authority-data = base64encode(local.cluster_ca_certificate)
        server                     = "https://${local.endpoint}:6443"
      }
    }
    contexts = {
      (local.cluster_name) = {
        cluster = local.cluster_name
        user    = local.cluster_name
      }
    }
    users = {
      (local.cluster_name) = {
        client-certificate-data = base64encode(local.client_certificate)
        client-key-data         = base64encode(local.client_key)
      }
    }
  }
}

resource "null_resource" "write_kubeconfig" {
  connection {
    type     = "ssh"
    host     = local.endpoint
    user     = "..."
    password = "..."
  }

  provisioner "file" {
    content     = yamlencode(module.kubeconfig.output)
    destination = "/etc/rancher/k3s/k3s.yaml"
  }
}
```

Note that wrapping variable references in parentheses (e.g. `(local.cluster_name) = {...}`) is required when used as keys in maps/objects.
