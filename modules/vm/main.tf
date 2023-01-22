terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

resource "libvirt_volume" "disk" {
  name   = var.name
  base_volume_id = var.base_volume_id
  #pool   = var.pool
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso${var.name}"
  user_data      = var.user_data
  network_config = var.network_config
  #pool           = var.pool
}

# Create the machine
resource "libvirt_domain" "vm" {
  name   = var.name
  memory = var.memory
  vcpu   = var.vcpu
  autostart = true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    macvtap = "enp0s25"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.disk.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  dynamic "filesystem" {
    for_each = var.filesystems
    content {
      source = filesystem.value["source"]
      target = filesystem.value["target"]
      readonly = filesystem.value["readonly"]
    }
  }
}