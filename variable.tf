variable "rgw_region" {
  default = "eu-west-2"
  description = "AWS region"
  type = string
}

variable "vpc_id" {
  default = "vpc-05ed6815d6c8c4f51"
  description = "This is default vpc id"
  type = string
}

variable "replication_instance_class" {
  default = "dms.t2.micro"
  description = "Instance default class"
  type = string
}

variable "analytical_to_redshift" {
  default = "analytical-to-redshift"
  description = "dms-replication-analytical-to-redshift"
  type = string
}


variable "mobile_to_analytical" {
  default = "mobile-to-analytical"
  description = "dms-replication-mobile-to-analytical"
  type = string
}
###########################################################
# First source endpoint#

variable "THX_ANALYTICAL_POSTGRES_DB_USERNAME" {
  # default = "DB_USERNAME"
  description = "thx-analytical-postgres_DB_USERNAME"
  type = string
}

variable "THX_ANALYTICAL_POSTGRES_DB_PASSWORD" {
  # default = "DB_PASSWORD"
  description = "thx-analytical-postgres_DB_PASSWORD"
  type = string
}

variable "thx-analytical-postgres_DB_Port" {
  default = "5432"
  description = "thx-analytical-postgres_DB_Port"
  type = string
}

variable "thx-analytical-postgres_DB_Name" {
  default = "postgres"
  description = "thx-analytical-postgres_DB_Name"
  type = string
}

variable "thx-analytical-postgres_rds_endpoint" {
  default = "postgredb.cmgmedqltlnk.eu-west-2.rds.amazonaws.com"
  description = "thx-analytical-postgres_DB AWS RDS postgresql endpoint"
  type = string
}
#############################################################

#Second source endpoint#
variable "MEMO2_DEV_PROD_POSTGRES_DB_USERNAME" {
  # default = "DB_USERNAME"
  description = "memo2-dev-prod-postgres_DB_USERNAME"
  type = string
}

variable "MEMO2_DEV_PROD_POSTGRES_DB_PASSWORD" {
  # default = "DB_PASSWORD"
  description = "memo2-dev-prod-postgres_DB_PASSWORD"
  type = string
}

variable "memo2-dev-prod-postgres_DB_Port" {
  default = "5432"
  description = "memo2-dev-prod-postgres_DB_Port"
  type = string
}

variable "memo2-dev-prod-postgres_DB_Name" {
  default = "postgres"
  description = "memo2-dev-prod-postgres_DB_Name"
  type = string
}

variable "memo2-dev-prod-postgres_rds_endpoint" {
  default = "memo2-dev-prod.cmgmedqltlnk.eu-west-2.rds.amazonaws.com"
  description = "memo2-dev-prod-postgres_DB AWS RDS postgresql endpoint"
  type = string
}
#################################################################################



#AWS RDS redshift cluster variable
####################################
variable "THX_ANALYTICAL_REDSHIFT_MASTER_USERNAME" {
  # default = "DB_USERNAME"
  description = "thx-analytical-redshift_master_username"
  type = string
}

variable "THX_ANALYTICAL_REDSHIFT_MASTER_PASSWORD" {
  # default = "DB_PASSWORD"
  description = "thx-analytical-redshift_master_password"
  type = string
}


variable "thx-analytical-redshift_database_name" {
  default = "redshiftdb"
  description = "thx-analytical-redshift_database_name"
  type = string
}

variable "thx-analytical-redshift_node_type" {
  default = "dc2.large"
  description = "thx-analytical-redshift_node_type"
  type = string
}

variable "thx-analytical-redshift_cluster_type" {
  default = "multi-node"
  description = "thx-analytical-redshift_cluster_type"
  type = string
}

variable "thx-analytical-redshift_number_of_nodes" {
  default = "2"
  description = "thx-analytical-redshift_number_of_nodes"
  type = string
}

variable "thx-analytical-redshift_port" {
  default = "5439"
  description = "thx-analytical-redshift_port"
  type = string
}



#memo2-analytics-prod vari

variable "memo2-analytics-prod-postgres_rds_endpoint" {
  default = "memo2-analytics-prod.cmgmedqltlnk.eu-west-2.rds.amazonaws.com"
  description = "memo2-analytics-prod-postgres_DB AWS RDS postgresql endpoint"
  type = string
}
