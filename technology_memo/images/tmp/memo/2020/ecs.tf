#
# Ai/Algorithm infrastructure
#

# Fundamental settings of ACM-ECS cluster

resource "" {
  count = ""
  name  = ""
}

resource "" {
  count                = ""
  name_prefix          = ""
  image_id             = ""
  instance_type        = ""
  iam_instance_profile = ""
  key_name             = ""
  user_data            = ""
  security_groups      = [
                           "",
                           "",
                           "",
                           ""
                         ]

  root_block_device {
    delete_on_termination = ""
    volume_type           = ""
    volume_size           = ""
  }

/*
  ebs_block_device {
    delete_on_termination = ""
    device_name           = ""
    volume_type           = ""
    volume_size           = ""
  }
*/

/*
  ebs_block_device {
    delete_on_termination = ""
    device_name           = ""
    volume_type           = ""
    volume_size           = ""
  }
*/

  lifecycle {
    create_before_destroy = true
  }
}

data "" {
  count    = ""
  template = ""

  vars {
    cluster_name            = ""
    ldap_server             = ""
    twistlock_hostname      = ""
    admin_user              = ""
    aggregator_host         = ""
    subsystem_id            = ""
    s3_bucket               = ""
    s3_blue_resource        = ""
    sep_environment         = ""
    jenkins-key             = ""
    login_allowed_groups    = ""
    s3_bucket_infra         = ""
    envstage                = ""
    ossec_server_host       = ""
    ossec_client_key        = ""
    ossecagt_pub_key        = ""
  }
}

resource "" {
  count                     = ""
  name                      = ""
  max_size                  = ""
  min_size                  = ""
  health_check_grace_period = 300
  health_check_type         = ""
  desired_capacity          = ""
  force_delete              = true
  launch_configuration      = ""
  vpc_zone_identifier       = [""]

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  tag {
    key                 = ""
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [""]
  }
}

# ECS Cluster Autoscaling Settings

## Autoscaling policies

resource "" {
  count                  = ""
  name                   = ""
  scaling_adjustment     = 1
  adjustment_type        = ""
  cooldown               = 300
  autoscaling_group_name = ""
}

resource "" {
  count                  = ""
  name                   = ""
  scaling_adjustment     = -1
  adjustment_type        = ""
  cooldown               = 300
  autoscaling_group_name = ""
}


resource "" {
  count           = ""
  name            = ""
  cluster         = ""
  task_definition = ""
  launch_type     = ""
  scheduling_strategy = ""

  lifecycle {
    ignore_changes = [
      ""
    ]
  }
}

#### Scaling thresholds for MemoryReservation
##resource "" {
##  count               = ""
##  alarm_name          = ""
##  comparison_operator = ""
##  evaluation_periods  = ""
##  metric_name         = ""
##  namespace           = ""
##  period              = ""
##  statistic           = ""
##  threshold           = ""
##  treat_missing_data  = ""
##  depends_on          = [""]
##
##  dimensions {
##    ClusterName = ""
##  }
##
##  alarm_actions = [""]
##}
##
##resource "" {
##  count               = ""
##  alarm_name          = ""
##  comparison_operator = ""
##  evaluation_periods  = ""
##  metric_name         = ""
##  namespace           = ""
##  period              = ""
##  statistic           = ""
##  threshold           = ""
##  treat_missing_data  = ""
##  depends_on          = [""]
##
##  dimensions {
##    ClusterName = ""
##  }
##
##  alarm_actions = [""]
##}
##
#### Scaling thresholds for CPUReservation
##resource "" {
##  count               = ""
##  alarm_name          = ""
##  comparison_operator = ""
##  evaluation_periods  = ""
##  metric_name         = ""
##  namespace           = ""
##  period              = ""
##  statistic           = ""
##  threshold           = ""
##  treat_missing_data  = ""
##  depends_on          = [""]
##
##  dimensions {
##    ClusterName = ""
##  }
##
##  alarm_actions = [""]
##}
##
##resource "" {
##  count               = ""
##  alarm_name          = ""
##  comparison_operator = ""
##  evaluation_periods  = ""
##  metric_name         = ""
##  namespace           = ""
##  period              = ""
##  statistic           = ""
##  threshold           = ""
##  treat_missing_data  = ""
##  depends_on          = [""]
##
##  dimensions {
##    ClusterName = ""
##  }
##
##  alarm_actions = [""]
##}
##
