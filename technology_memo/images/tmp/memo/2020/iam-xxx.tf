#
# Custom ecs s3 access policy
#
resource "" {
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
        "",
        "",
        ""
      ]
    },
    {
      "",
      "": [
        "",
        ""
      ],
      "": [
        "",
        "",
        "",
        ""
      ]
    }
  ]
}
EOF
}

#
# Blue monitoring
#
resource "" {
  depends_on = [""]
  role       = ""
  policy_arn = ""
}


#
# fluentd aggregator send logs to s3 for backup
#
resource "" {
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
        ""
      ],
      "": [
        ""
      ]
    },
    {
      "",
      "": [
        ""
      ],
      "": [
        ""
      ]
    }
  ]
}
EOF
}
