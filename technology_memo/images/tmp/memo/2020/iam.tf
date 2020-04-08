#
# ECS
#
resource "" {
  depends_on = [""]
  name       = ""
  role       = ""
}

resource "" {
  name = ""

  assume_role_policy = <<EOF
{
  "",
  "": [
    {
      "",
      "",
      "": {
        ""
      },
      ""
    }
  ]
}
EOF
}

resource "" {
  depends_on = [""]
  role       = ""
  policy_arn = ""
}

resource "" {
  depends_on = [""]
  role       = ""
  policy_arn = ""
}

#
# RDS
#
resource "" {
  name  = ""

  assume_role_policy = <<EOF
{
  "",
  "": [
    {
      "",
      "",
      "": {
        ""
      },
      ""
    }
  ]
}
EOF
}

resource "" {
  depends_on = [""]
  role       = ""
  policy_arn = ""
}

#
#  Scheduled Task of Jobchecker Agent
#
resource "" {
  count      = ""
  name       = ""

  assume_role_policy = <<EOF
{
  "",
  "": [
    {
      "",
      "",
      "": {
        ""
      },
      ""
    }
  ]
}
EOF
}

resource "" {
  count      = ""
  depends_on = [""]
  role       = ""
  policy_arn = ""
}

resource "" {
  count      = ""
  name       = ""

  assume_role_policy = <<EOF
{
  "",
  "": [
    {
      "",
      "",
      "": {
        ""
      },
      ""
    }
  ]
}
EOF
}

resource "" {
  count      = ""
  name       = ""
  role       = ""

  policy = <<EOF
{
  "",
  "": [
    {
      "",
      "": [
        "",
        "",
        "",
        ""
      ],
      "": {
        "": {
         ""
        }
      },
      ""
    }
  ]
}
EOF
}

#
# jp1node
#
resource "" {
  count      = ""
  name       = ""
  role       = ""
}

resource "" {
  count       = ""
  name        = ""
  description = ""

  assume_role_policy = <<EOF
{
  "",
  "": [
    {
      "",
      "": {
        ""
      },
      ""
    }
  ]
}
EOF
}

resource "" {
  count      = ""
  depends_on = [""]
  name       = ""
  role       = ""

  policy = <<EOF
{
  "",
  "": [
    {
      "",
      "": [
        "",
        "",
        "",
        ""
      ],
      "": [
        "",
        "",
        "",
        ""
      ]
    },
    {
      "",
      "": [
        ""
      ],
      "": [
        "",
        ""
      ]
    }
  ]
}
EOF
}

resource "" {
  count      = ""
  depends_on = [""]
  name       = ""
  role       = ""

  policy = <<EOF
{
  "",
  "": [
    {
      "",
      "": [
        "",
        "",
        "",
        ""
      ],
      "": {
        "": {
         ""
        }
      },
      ""
    },
    {
      "",
      "",
      ""
    },
    {
      "",
      "",
      ""
    }
  ]
}
EOF
}

resource "" {
  count      = ""
  depends_on = [""]
  name       = ""
  role       = ""

  policy = <<EOF
{
  "",
  "": [
    {
      "",
      "": [
          "",
          "",
          ""
      ],
      ""
    }
  ]
}
EOF
}

resource "" {
  count      = ""
  depends_on = [""]
  role       = ""
  policy_arn = ""
}


resource "" {
  count      = ""
  depends_on = [""]
  name       = ""
  role       = ""

  policy = <<EOF
{
  "",
  "": [
    {
      "",
      "",
      "": [
        ""
      ]
    }
  ]
}
EOF
}
