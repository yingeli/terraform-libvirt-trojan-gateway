terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.10"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu+ssh://yingeli@192.168.68.9/system"
}