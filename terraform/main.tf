terraform {
  required_providers {
	openstack = {
  	source  = "terraform-provider-openstack/openstack"
  	version = "~> 1.52.1"
	}
  }
}

provider "openstack" {
  auth_url	= "https://cloud.api.selcloud.ru/identity/v3"
  domain_id = var.domain_id
  tenant_id   = var.tenant_id
  user_name   = var.user_name
  password	= var.password
  region  	= var.region
}

resource "openstack_compute_instance_v2" "controller" {
  name    	= "slurm-controller"
  image_name  = "Ubuntu 22.04 LTS 64-bit "
  flavor_name = "SL1.1-1024-8"
  key_pair	= "Vienna"
  network {
	uuid = "33531703-4fdb-42ec-a943-e6874615df51"
  }
}

resource "openstack_compute_instance_v2" "compute" {
  count   	= 2
  name    	= "slurm-compute-${count.index + 1}"
  image_name  = "Ubuntu 22.04 LTS 64-bit "
  flavor_name = "SL1.1-1024-8"
  key_pair	= "Vienna"
  network {
	uuid = "33531703-4fdb-42ec-a943-e6874615df51"
  }
}

output "controller_ip" {
  value = openstack_compute_instance_v2.controller.access_ip_v4
}

output "compute_ips" {
  value = [for vm in openstack_compute_instance_v2.compute : vm.access_ip_v4]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("${path.module}/inventory.tftpl", {
    controller_ip = openstack_compute_instance_v2.controller.access_ip_v4
    compute_ips   = openstack_compute_instance_v2.compute[*].access_ip_v4
  })
}