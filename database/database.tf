
output "ip" {
  value = "${openstack_compute_instance_v2.mysql.access_ip_v4}"
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

resource "openstack_compute_keypair_v2" "mysql_key" {
  name="interop-mysql-key"
  public_key="${var.public_key}"
}

resource "openstack_compute_floatingip_v2" "mysql_floating" {
  pool = "floating"
}

resource "openstack_compute_instance_v2" "mysql" {
    region = ""
    name = "interop-mysql-1"
    image_name = "${var.image_name}"
    flavor_name = "${var.flavor_name}"
    key_pair = "interop-mysql-key"
    security_groups = ["interop"]
    network {
        access_network = true
        name = "fixed"
        floating_ip = "${openstack_compute_floatingip_v2.mysql_floating.address}"
    }
}
