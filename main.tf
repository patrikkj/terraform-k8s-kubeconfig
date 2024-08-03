locals {
  kubeconfig = try(yamldecode(file(var.path)), {})

  in_clusters   = { for cluster in try(local.kubeconfig.clusters, {}) : cluster.name => cluster.cluster }
  in_contexts   = { for context in try(local.kubeconfig.contexts, {}) : context.name => context.context }
  in_extensions = { for extension in try(local.kubeconfig.extensions, {}) : extension.name => extension.extension }
  in_users      = { for user in try(local.kubeconfig.users, {}) : user.name => user.user }

  patched_clusters   = merge(local.in_clusters, coalesce(var.patch.clusters, {}))
  patched_contexts   = merge(local.in_contexts, coalesce(var.patch.contexts, {}))
  patched_extensions = merge(local.in_extensions, coalesce(var.patch.extensions, {}))
  patched_users      = merge(local.in_users, coalesce(var.patch.users, {}))

  out_clusters   = var.replace.clusters != null ? coalesce(var.replace.clusters, {}) : local.patched_clusters
  out_contexts   = var.replace.contexts != null ? coalesce(var.replace.contexts, {}) : local.patched_contexts
  out_extensions = var.replace.extensions != null ? coalesce(var.replace.extensions, {}) : local.patched_extensions
  out_users      = var.replace.users != null ? coalesce(var.replace.users, {}) : local.patched_users

  // Spec: https://kubernetes.io/docs/reference/config-api/kubeconfig.v1
  output = {
    apiVersion      = "v1"
    kind            = "Config"
    preferences     = coalesce(var.preferences, try(local.kubeconfig["preferences"], {}))
    current-context = coalesce(var.current-context, try(local.kubeconfig["current-context"], null))
    clusters        = [for name, cluster in local.out_clusters : { "name" : name, "cluster" : cluster }]
    contexts        = [for name, context in local.out_contexts : { "name" : name, "context" : context }]
    users           = [for name, user in local.out_users : { "name" : name, "user" : user }]
    extensions      = [for name, extension in local.out_extensions : { "name" : name, "extension" : extension }]
  }
}

resource "local_sensitive_file" "write_kubeconfig" {
  count = var.write ? 1 : 0

  filename = pathexpand(var.path)
  content  = yamlencode(local.output)
}
