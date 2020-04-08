#
# Common parameters
#

region                          = ""
region_short                    = ""
availability_zone               = [""]

# Naming and Tagging
environment                     = ""
jp1_environment                 = ""
dif_environment                 = ""

country                         = ""

envstage                        = ""
brand                           = ""
service_name                    = ""
system_id                       = ""
system_name                     = ""
subsystem_id                    = ""

domain                          = ""
segment                         = ""
segment_secure                  = ""

# Domain Name
delegate_domain                 = ""
org_delegate_domain             = ""
aeg_delegate_domain             = ""
aeg_org_delegate_domain         = ""

# EC2 Key
ec2_key                         = ""
common_key                      = ""

# EC2 Configuration in Userdata
ec2_userdata_config = {
  twistlock_hostname   = ""
  admin_user           = ""
  s3_blue_resource     = ""
  sep_environment      = ""
  ldap_server          = ""
  login_allowed_groups = ""
  ossec_server_host    = ""
  ossec_client_key     = ""
  ossecagt_pub_key     = ""
}

#
# Resources
#

# Standard EC2 Instance
ec2_ami                         = ""
ec2_ami_amzn                    = ""
ec2_ami_rh                      = ""
ecs_ami                         = ""
ec2_ami_win                     = ""
base_instance_type              = ""

# jp1node
jp1node_maintenance_enable      = ""
jp1node_pub_keys = {
  jenkins-key                   = ""
  central-jp1node-key           = ""
  jobuser-key-1                 = ""
  jobuser-key-2                 = ""
  jobuser02-key-1               = ""
  jobuser02-key-2               = ""
}

# ECS Container Instance
ecs_enabled                     = ""
ecs_instance_type               = ""  #Prod
ecs_desired_count               = ""
asg_max_size                    = ""
asg_min_size                    = ""
asg_desire_size                 = ""
ecs_pub_keys = {
  jenkins-key                   = ""
}

# Postgres switch
postgres_enabled                = ""
postgres_read_counts            = ""
postgres_instance_type          = ""
postgres_read_instance_type     = ""

# Postgres acm switch
postgres_acm = {
  db_name       = ""
  db_schema     = ""
  db_port       = ""
  acmbatch_user_name     = ""
  acmbatch_user_password = ""
  aspbatch_user_name     = ""
  aspbatch_user_password = ""
}

# Redshift switch
redshift_enabled                = ""
redshift_instance_type          = ""    # prodduction
redshift_instance_type_asp      = ""    # prodduction


# Aurora switch
aurora_enabled                  = ""
aurora_slave_counts             = ""
aurora_instance_type            = ""

# SecurityGroup
# Necessary or unnecessary
aws_sg_comsecpro-ecs-blue       = ""
aws_sg_acm_talend               = ""
aws_sg_jenkins                  = ""
aws_sg_blue                     = ""
data-integration                = ""


external_sg_identifier = [
  "",
  "",
  "",
  "",
]

blue_monitoring_sg_for_ecs      = "" # 
blue_monitoring_sg_for_ec2      = "" # 

aws_sg_sep_cidr                 = ""

# IAM Role
# Necessary or unnecessary
arn_role_AmazonEC2ContainerServiceforEC2Role = ""
arn_role_stg01-planexec-logmonitoring-blue = ""

iam_policy_ECSforEC2Role        = ""
iam_policy_PlanLogMonitor       = ""
iam_policy_SecretsManager       = ""

# Monitoring task
ecs_task_monitoring         = ""

# s3 common bucket switch
s3_common_enabled               = ""

# ELB
aws_lb_account_id               = ""

# Whitelist server IP
whitelist_server_ip              = [""]
maintenance_ip                   = []


#
# Secrets
#

# Redshift
redshift = {
  db_name       = ""
  db_port       = ""
  db_schema     = ""
  user_name     = ""
  user_password = ""
  nodes         = ""                     # production 3
  automated_snapshot_retention_period = ""
  maintenance_window = ""
}

# Redshift users
redshift_user_ = {
  user_name     = ""
  user_password = ""
}

redshift_user_aspope = {
  user_name     = ""
  user_password = ""
}

redshift_user_aspview = {
  user_name     = ""
  user_password = ""
}

redshift_user_aspbatch = {
  user_name     = ""
  user_password = ""
}


redshift_user_acmif = {
  user_name     = ""
  user_password = ""
}


kms_id                          = ""

# Postgres
postgres = {
  db_name       = ""
  user_name     = ""
  user_password = ""
}

# Aurora
aurora = {
  db_name       = ""
  user_name     = ""
  user_password = ""
}

# Fluentd
fluentd_ecr                     = ""
fluentd_version                 = ""
fluentd_desired_count           = ""

# The setting value refers to the following.
# https://github.com/*/README.md
fluentd_configure = {
  log_aggregator                = ""
  log_aggregator_port           = ""
  s3_logging_bucket             = ""
  s3_region                     = ""
  logging_server_host           = ""
  logging_server_port           = ""
  s3_next_label                 = ""
  logging_next_label            = ""
  suppressor_next_label         = ""
}

# jp1node
jp1node_enabled                 = ""
jp1node_counts                  = ""
ec2_jp1node_ami                 = ""
jp1_instance_type               = ""
asg_jp1_ami                     = ""

# migration test
migration_test_enabled          = ""




