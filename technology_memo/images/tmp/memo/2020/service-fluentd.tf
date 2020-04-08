resource "" {
  count = ""
  name           = ""
  description    = ""
  vpc_id         = ""

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = ""
    cidr_blocks = [""]
  }

  ingress {
    from_port    = 24224
    to_port      = 24224
    protocol     = ""
    cidr_blocks  = [""]
  }

  tags {
    ""
  }
}

resource "" {
  count                      = ""
  name                       = ""
  subnets                    = [""]
  internal                   = true
  load_balancer_type         = ""
  enable_deletion_protection = false

  tags {
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
    ""
  }
}

resource "" {
  count              = ""
  load_balancer_arn  = ""
  port               = ""
  protocol           = ""

  default_action {
    target_group_arn = ""
    type             = ""
  }
}

resource "" {
  count                = ""
  name                 = ""
  port                 = 24224
  protocol             = ""
  vpc_id               = ""
  deregistration_delay = 60
  target_type          = ""

  health_check {
    interval            = 30
    port                = ""
    protocol            = ""
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

}

resource "" {
  count                        = ""
  depends_on                   = [""]
  name                         = ""
  cluster                      = ""
  task_definition              = ""
  desired_count                = ""

  network_configuration {
    subnets                    = [""]
    security_groups            = [""]
    assign_public_ip           = ""
  }

  load_balancer {
    target_group_arn           = ""
    container_name             = ""
    container_port             = ""
  }

  ordered_placement_strategy {
    type                       = ""
    field                      = ""
  }

  ordered_placement_strategy {
    type                       = ""
    field                      = ""
  }
}

data "" {
  count    = ""
  template = ""
  vars {
    environment                = ""
    region                     = ""
    account_id                 = ""
    ecr_name                   = ""
    label                      = ""
    service_name               = ""
    aggregator                 = ""
    aggregator_port            = ""
    subsystem_id               = ""
    s3_logging_bucket          = ""
    s3_region                  = ""
    logging_server_host        = ""
    logging_server_port        = ""
    s3_next_label              = ""
    logging_next_label         = ""
    suppressor_next_label      = ""
  }
}

resource "" {
  count                        = ""
  family                       = ""
  container_definitions        = ""
  network_mode                 = ""
}

resource "" {
  count      = ""
  depends_on = [""]
  zone_id    = ""
  name       = ""
  type       = ""

  alias {
    name                   = ""
    zone_id                = ""
    evaluate_target_health = true
  }
}
