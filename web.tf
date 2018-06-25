provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source = "github.com/tahir24434/tf_vpc.git?ref=v0.0.1"
  name = "web"
  cidr_block = "${var.region == "us-west-1" ? "10.0.0.0/16" : "172.16.0.0/16"}"
  public_subnet = "10.0.1.0/24"
}

resource "aws_instance" "web" {
  ami = "${var.ami[var.region]}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  subnet_id = "${module.vpc.public_subnet_id}"
  associate_public_ip_address = true
  user_data = "${file("files/web_bootstrap.sh")}"
  vpc_security_group_ids = ["${aws_security_group.web_host_sg.id}",]
  private_ip = "${var.environment == "dev" ? var.dev_instance_ips[count.index] : var.prod_instance_ips[count.index]}"
  tags {
    Name = "web-${format("%03d", count.index)}"
    # element function pulls an element from a list using the given index and wraps when it
    # reaches the end of the list.
    Owner = "${element(var.owner_tag, count.index)}"
  }
  count = instances_count
}

resource "aws_elb" "web" {
  name = "web-elb"
  subnets = ["${module.vpc.public_subnet_id}"]
  security_groups = ["${aws_security_group.web_inbount_sg.id}"]
  "listener" {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  instances = ["${aws_instance.web.*.id}"]
}

resource "aws_security_group" "web_inbound_sg" {
  name        = "web_inbound"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_host_sg" {
  name        = "web_host"
  description = "Allow SSH & HTTP to web hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}