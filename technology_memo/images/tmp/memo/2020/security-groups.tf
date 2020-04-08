resource "" {
  name        = ""
  description = ""
  vpc_id      = ""

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = ""
    cidr_blocks     = [""]
  }

  tags {
    Name = ""
  }
}

resource "" {
    type                     = ""
    protocol                 = ""
    from_port                = 0
    to_port                  = 0
    security_group_id        = ""
    self                     = true
}

resource "" {
    type                     = ""
    protocol                 = ""
    from_port                = 0
    to_port                  = 0
    security_group_id        = ""
    source_security_group_id = ""
}

resource "" {
    count             = ""
    type              = ""
    protocol        = ""
    from_port       = 0
    to_port         = 0
    security_group_id = ""
    source_security_group_id = ""
}

resource "" {
  count       = ""
  name        = ""
  description = ""
  vpc_id      = ""

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = ""
    cidr_blocks = [""]
  }

  tags {
    ""
  }
}

resource "" {
    count             = ""
    type              = ""
    from_port         = 22
    to_port           = 22
    protocol          = ""
    cidr_blocks       = [""]
    security_group_id = ""
}
  
resource "" {
    count             = ""
    type              = ""
    from_port         = 24224
    to_port           = 24224
    protocol          = ""
    cidr_blocks       = [""]
    security_group_id = ""
}
  
resource "" {
  count       = ""
  name        = ""
  description = ""
  vpc_id      = ""

  tags {
    ""
  }
}

resource "" {
  count             = ""
  type              = ""
  from_port         = 0
  to_port           = 0
  protocol          = ""
  cidr_blocks       = [""]
  security_group_id = ""
}

resource ""{
  count             = ""
  type              = ""
  from_port         = 22
  to_port           = 22
  protocol          = ""
  cidr_blocks       = [""]
  security_group_id = ""
}

resource "" {
  count             = ""
  type              = ""
  from_port         = 22
  to_port           = 22
  protocol          = ""
  cidr_blocks       = [""]
  security_group_id = ""
}

resource "" {
  count             = ""
  name              = ""
  description       = ""
  vpc_id            = ""

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = ""
    cidr_blocks     = [""]
  }
}

resource "" {
  count                    = ""
  type                     = ""
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = ""
  security_group_id        = ""
}

resource "" {
  count                    = ""
  type                     = ""
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  cidr_blocks              = [""]
  security_group_id        = ""
}

locals {
  rule_source_sg = [
    "",
    ""
  ]
}

resource "" {
  count                    = ""
  type                     = ""
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = ""
  security_group_id        = ""
}
