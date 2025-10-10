/**
 *
 *
 */


resource "aws_lb" "ecs" {
  name                       = "${var.cluster_name}-ext"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = var.subnets
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.delete_protection
  security_groups            = [aws_security_group.ext.id]

  tags = {
    Environment = var.environment,
    Creator     = "Terraform",
    Name        = "${var.cluster_name}-ext",
  }
}

resource "aws_security_group" "ext" {
  name        = "${var.cluster_name}-ext"
  description = "security group for ext ALB"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "in443" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22", "10.3.0.0/16", "10.2.0.0/16", "10.1.0.0/16", "50.232.8.34/32", "192.168.16.0/20", "192.168.11.0/24"]

  security_group_id = aws_security_group.ext.id
}

resource "aws_security_group_rule" "in80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/13", "104.24.0.0/14", "172.64.0.0/13", "131.0.72.0/22", "10.3.0.0/16", "10.2.0.0/16", "10.1.0.0/16", "50.232.8.34/32", "192.168.16.0/20", "192.168.11.0/24"]

  security_group_id = aws_security_group.ext.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ext.id
}



# create listener
resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.amazon_issued.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
  lifecycle {
    create_before_destroy = true
  }
}

# create listener
resource "aws_lb_listener" "ecs2" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
  lifecycle {
    create_before_destroy = true
  }
}


# create target group for lb
#resource "aws_lb_target_group" "ecs" {
#  name        = "${var.cluster_name}-ext"
#  port        = var.port
#  protocol    = "HTTP"
#  target_type = "ip"
#  vpc_id      = var.vpc_id
#
#  health_check {
#    path                = "/health"
#    port                = 80
#    healthy_threshold   = 5
##    unhealthy_threshold = 2
#    timeout             = 5
#    interval            = 30
#    matcher             = "200" # has to be HTTP 200 or fails
#  }

#  lifecycle {
#    create_before_destroy = true
#  }
#}

module "load_balancer_associations" {
  source = "/Users/vivektrivedi/Desktop/Legacy/Test_Code_TF_TG/legacy_terragrunt/terragrunt/ec2-terragrunt/terraform-modules/helpers/load-balancer-associations"

  associations = var.load_balancer_associations
}

resource "aws_lb_target_group" "ecs" {
  #for_each = module.load_balancer_associations.associations

  name   = "${var.cluster_name}-ext"
  vpc_id = var.vpc_id

  port        = "80" // FIXME: This always works, but why? Find the documentation. Is this the port the lb sends traffic to the target group?
  protocol    = "HTTP"
  target_type = "ip"

  slow_start           = module.load_balancer_associations.associations.app.slow_start
  deregistration_delay = module.load_balancer_associations.associations.app.deregistration_delay

  health_check {
    protocol = module.load_balancer_associations.associations.app.health_check_protocol
    port     = module.load_balancer_associations.associations.app.health_check_port

    path                = module.load_balancer_associations.associations.app.health_check_path
    matcher             = module.load_balancer_associations.associations.app.health_check_matcher
    timeout             = module.load_balancer_associations.associations.app.health_check_timeout
    interval            = module.load_balancer_associations.associations.app.health_check_interval
    healthy_threshold   = module.load_balancer_associations.associations.app.health_check_healthy_threshold
    unhealthy_threshold = module.load_balancer_associations.associations.app.health_check_unhealthy_threshold
  }

  tags = {
    Name = "${var.cluster_name}-ext"
  }

  lifecycle {
    create_before_destroy = true
  }
}


data "aws_route53_zone" "selected" {
  name = element(regexall("[\\w-]+\\.[\\w-]+\\.?$", var.external_domain), 0)
}

data "aws_acm_certificate" "amazon_issued" {
  domain      = "*.${element(regexall("[\\w-]+\\.[\\w-]+\\.?$", var.external_domain), 0)}"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}


resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.external_domain
  type    = "CNAME"
  ttl     = 3600

  records = [aws_lb.ecs.dns_name]

  allow_overwrite = true
}

