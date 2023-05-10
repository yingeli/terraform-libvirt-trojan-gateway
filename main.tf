# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu-2004-minimal" {
  name   = "ubuntu-2004-minimal"
  source = "https://cloud-images.ubuntu.com/minimal/releases/focal/release/ubuntu-20.04-minimal-cloudimg-amd64.img"
  format = "qcow2"
}

data "template_file" "user_config" {
  template = file("${path.module}/user_config.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

data "template_file" "server_config" {
  template = file("${path.module}/server_config.cfg")

  vars = {
    trojan_server    = "ygtr.southeastasia.cloudapp.azure.com"
    trojan_password  = "abcd1234!"    
    trojan_port      = 1080
  }
}

data "template_cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "user_config.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.user_config.rendered}"
  }

  part {
    filename     = "server_config.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.server_config.rendered}"
  }
}

module "trojan-gateway" {
  source = "./modules/vm"
  providers = {
    libvirt = libvirt
  }
  name           = "trojan-gateway"
  base_volume_id = libvirt_volume.ubuntu-2004-minimal.id
  #pool           = libvirt_pool.images.name
  user_data      = data.template_cloudinit_config.user_data.rendered
  network_config = data.template_file.network_config.rendered
  memory         = 512
  vcpu           = 1
}