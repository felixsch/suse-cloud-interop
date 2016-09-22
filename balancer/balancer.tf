
output "ip" {
  value = "${openstack_compute_instance_v2.balancer.access_ip_v4}"
}

variable "public_key" {
  description = "public key to use"
  type = "string"
}

variable "image_name" {
  description = "cloud image name"
  type = "string"
  default = "SLE12-SP1"
}

variable "flavor_name" {
  description = "name of flavor to use"
  type = "string"
  default = "m1.smaller"
}

resource "openstack_compute_keypair_v2" "balancer_key" {
  name="interop-balancer-key"
  public_key="${var.public_key}"
}

resource "openstack_compute_floatingip_v2" "balancer_floating" {
  pool = "floating"
}

resource "openstack_compute_instance_v2" "balancer" {
    region = ""
    name = "interop-balancer-1"
    image_name = "${var.image_name}"
    flavor_name = "${var.flavor_name}"
    key_pair = "interop-balancer-key"
    security_groups = ["default"]

    network {
        access_network = true
        name = "fixed"
        floating_ip = "${openstack_compute_floatingip_v2.balancer_floating.address}"
    }
}
