terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

variable "network_host_if" {
  type    = string
  default = "Intel(R) Wi-Fi 6E AX211 160MHz"
}

resource "virtualbox_vm" "machine_debian" {
  count= 1
  name   = "finaldefinalversiondebian3"
  # Image officielle Debian, très stable
  image  = "https://app.vagrantup.com/generic/boxes/debian11/versions/4.3.12/providers/virtualbox.box"
  cpus   = 2
  memory = "2048 mib"

  # Adaptateur 1 : Mode Bridge sur ton Wi-Fi
  network_adapter {
    type           = "bridged"
    host_interface = var.network_host_if
  }

 }
