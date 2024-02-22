resource "aws_launch_configuration" "web_app_lc" {
  name            = "web-app-lc1"
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.web_app_instance_sg.id]
  # Root Block Device for the application/services
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }

  # Additional EBS Block Device for storing log data
  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd

    # Get private IP address of the instance
    private_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

    echo "<html>
            <head>
                <style>
                    body {
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                        text-align: center;
                        margin: 50px;
                        background-color: #f2f2f2;
                    }
                    h1 {
                        color: #333;
                    }
                    p {
                        color: #777;
                        font-size: 18px;
                    }
                </style>
            </head>
            <body>
                <h1>Welcome to the Demo App!</h1>
                <p>This server is hosted on instance with private IP:</p>
                <h2>$private_ip</h2>
            </body>
          </html>" > /var/www/html/index.html

    systemctl enable httpd
EOF



  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_autoscaling_group" "web_app_asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_instances
  min_size             = var.min_instances
  launch_configuration = aws_launch_configuration.web_app_lc.id
  vpc_zone_identifier  = var.public_subnets

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "web-app-instance"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id

  # Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTPS (Port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for SSH (Port 22) - Management Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Replace with your management IP address
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_security_group" "web_app_instance_sg" {
  vpc_id = var.vpc_id

  # Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress rule for HTTP (Port 80) and HTTPS (Port 443) from the load balancer
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
  # Ingress rule for SSH (Port 22) - Management Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Replace with your management IP address
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "web-app-instance-sg"
  }
}



resource "aws_lb" "web_app_lb" {
  name               = "web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.public_subnets
}

resource "aws_lb_listener" "web_app_listener_https" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
    type             = "forward"
  }
}

# HTTP Listener on port 80
# resource "aws_lb_listener" "web_app_listener_http" {
#   load_balancer_arn = aws_lb.web_app_lb.arn
#   port              = 443
#   protocol          = "HTTPS"

#   default_action {
#     target_group_arn = aws_lb_target_group.web_app_target_group.arn
#     type             = "forward"
#   }
# }

resource "aws_lb_target_group" "web_app_target_group" {
  name        = "web-app-target-group"
  port        = 80     # Change this to 443 for HTTPS
  protocol    = "HTTP" # Change this to HTTPS for 443
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_autoscaling_attachment" "web_app_asg_attachment" {
  alb_target_group_arn   = aws_lb_target_group.web_app_target_group.arn
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

resource "aws_route53_zone" "private_zone" {
  name = "example.com"

  vpc {
    vpc_id = var.vpc_id
  }
}


resource "aws_route53_record" "test_record" {
  zone_id = aws_route53_zone.private_zone.id
  name    = "test.example.com"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.web_app_lb.dns_name]
}



# Output the Load Balancer DNS Name
output "web_app_lb_dns_name" {
  value = aws_lb.web_app_lb.dns_name
}
