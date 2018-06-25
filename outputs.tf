output "elb_address" {
  value = "${aws_elb.web.dns_name}"
}

output "pub_addresses" {
  value = "${aws_instance.web.*.public_ip}"
}

output "priv_addresses" {
  value = "${aws_instance.web.*.private_ip}"
}

output "public_subnet_id" {
  value = "${module.vpc.public_subnet_id}"
}