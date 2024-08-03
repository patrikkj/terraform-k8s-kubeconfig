variable "path" {
  type        = string
  default     = "~/.kube/config"
  description = "Path to kubeconfig file."
}

variable "write" {
  type        = bool
  default     = false
  description = "Whether to write the updated kubeconfig to the source file."
}

variable "current-context" {
  type        = string
  default     = null
  description = <<-EOT
  If set, updates the current context.
  If no kubeconfig file exists, 'current-context' must be defined as it is required by the kubeconfig spec.
  (link: https://kubernetes.io/docs/reference/config-api/kubeconfig.v1)
  EOT
}

variable "preferences" {
  type        = any
  default     = null
  description = "If set, updates the preferences field."
}

variable "patch" {
  type = object({
    clusters   = optional(map(any))
    contexts   = optional(map(any))
    users      = optional(map(any))
    extensions = optional(map(any))
  })
  default     = {}
  description = "Adds or replaces the specified entries based on the `name` field."
}

variable "replace" {
  type = object({
    clusters   = optional(map(any))
    contexts   = optional(map(any))
    users      = optional(map(any))
    extensions = optional(map(any))
  })
  default     = {}
  description = "Replaces all entries under the specified block in the config."
}
