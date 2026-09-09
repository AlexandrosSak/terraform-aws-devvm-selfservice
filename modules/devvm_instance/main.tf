resource "aws_launch_template" "this" {
  name_prefix   = "devvm-${var.dev}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
    subnet_id                   = var.subnet_id
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Initializing developer environment for ${var.dev}"
              /usr/local/bin/custom-dev-init.sh --user ${var.dev}
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "devvm-${var.dev}"
    })
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "devvm_${var.dev}"
  vpc_zone_identifier = [var.subnet_id]
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}