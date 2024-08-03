locals {
  cluster_name           = "my-cluster"
  endpoint               = "192.168.10.101"
  cluster_ca_certificate = base64encode("...")
  client_certificate     = base64encode("...")
  client_key             = base64encode("...")
}

module "kubeconfig" {
  source = "patrikkj/kubeconfig"
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
