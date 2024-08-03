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
