variable "name" {
  type = string
}

variable "base_volume_id" {
  type = string
}

#variable "pool" {
#  type = string
#}

variable "user_data" {
  type = string
}

variable "network_config" {
  type = string
}

variable "memory" {
  type = number
}

variable "vcpu" {
  type = number
}

variable "filesystems" {
  type = list(object({
    source   = string
    target   = string
    readonly = bool
  }))
  default = []
}