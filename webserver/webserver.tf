
output "ip" {
  value = "${join(" ", openstack_compute_instance_v2.webserver.*.access_ip_v4)}"
}

variable "webserver_count" {
  description = "number of webserver hosts"
  type = "string"
  default = "1"
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

resource "openstack_compute_keypair_v2" "webserver_key" {
  name="interop-webserver-key"
  public_key="${var.public_key}"
}

resource "openstack_compute_floatingip_v2" "webserver_floating" {
  count= "${var.webserver_count}"
  pool = "floating"
}

/* resource "openstack_compute_secgroup_v2" "lamp_security_group" { */
/*   name = "interop" */
/*   description = "Interop challange security group" */
/*   rule { */
/*     from_port = 22 */
/*     to_port = 22 */
/*     ip_protocol = "tcp" */
/*     cidr = "0.0.0.0/0" */
/*   } */
/*   rule { */
/*     from_port = 80 */
/*     to_port = 80 */
/*     ip_protocol = "tcp" */
/*     cidr = "0.0.0.0/0" */
/*   } */
/* } */

resource "openstack_compute_instance_v2" "webserver" {
    region = ""
    count = "${var.webserver_count}"
    name = "interop-webserver-${count.index}"
    image_name = "${var.image_name}"
    flavor_name = "${var.flavor_name}"
    key_pair = "interop-webserver-key"
    security_groups = ["default"]

    network {
        access_network = true
        name = "fixed"
        floating_ip = "${element(openstack_compute_floatingip_v2.webserver_floating.*.address, count.index)}"
    }
}
