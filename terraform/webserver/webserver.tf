
output "ip" {
  value = "${join(" ", openstack_compute_instance_v2.apache.*.access_ip_v4)}"
}

variable "apache_count" {
  description = "number of apache hosts"
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

resource "openstack_compute_keypair_v2" "apache_key" {
  name="interop-apache-key"
  public_key="${var.public_key}"
}

resource "openstack_compute_floatingip_v2" "apache_floating" {
  count= "${var.apache_count}"
  pool = "floating"
}

resource "openstack_compute_secgroup_v2" "lamp_security_group" {
  name = "interop-security-group"
  description = "Interop challange security group"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "apache" {
    region = ""
    count = "${var.apache_count}"
    name = "interop-apache-${count.index}"
    image_name = "${var.image_name}"
    flavor_name = "${var.flavor_name}"
    key_pair = "interop-apache-key"
    security_groups = ["interop-security-group"]
    metadata {
        demo = "metadata"
    }

    network {
        access_network = true
        name = "fixed"
        floating_ip = "${element(openstack_compute_floatingip_v2.apache_floating.*.address, count.index)}"
    }
}
