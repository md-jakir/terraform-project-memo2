
# DMS instance Security Group analytical-to-redshift
resource "aws_security_group" "analytical-to-redshift-sg" {
  name        = "analytical-to-redshift-sg"
  description = "analytical-to-redshift-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow Port 5439"
    from_port        = 5439
    to_port          = 5439
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow Port 5432"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all IPs and Port for outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "analytical-to-redshift-sg"
  }
}
###################################################
# DMS instance Security Group mobile-to-analytical
resource "aws_security_group" "mobile-to-analytical-sg" {
  name        = "mobile-to-analytical-sg"
  description = "mobile-to-analytical-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow Port 5439"
    from_port        = 5439
    to_port          = 5439
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow Port 5432"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all IPs and Port for outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mobile-to-analytical-sg"
  }
}

#############################################################
resource "aws_iam_role" "dms_role" {
  name = "DMSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dms_policy" {
  name        = "DMSPolicy"
  description = "Policy for DMS replication instance"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dms:CreateEndpoint",
          "dms:CreateReplicationInstance",
          "dms:CreateReplicationTask",
          "dms:TestConnection"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "rds-db:connect",
          "redshift:GetClusterCredentials"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dms_role_policy_attachment" {
  policy_arn = aws_iam_policy.dms_policy.arn
  role       = aws_iam_role.dms_role.name
}

resource "aws_dms_replication_subnet_group" "dms-subnet-group" {
   replication_subnet_group_description = "subnet group for DMS"
   replication_subnet_group_id  = "dms-subnet-group"
   subnet_ids = [ 
     "subnet-0e05e37b8371a855f",
     "subnet-0e85c6abddebe857a", 
     "subnet-02b080ed290bc7523"
    ]
 }

# this is analytical-to-redshift dms replication instance
resource "aws_dms_replication_instance" "analytical-to-redshift" {
  allocated_storage    = 20
  engine_version       = "3.5.1"
  publicly_accessible = true
  replication_instance_class = var.replication_instance_class
  replication_instance_id = var.analytical_to_redshift
  replication_subnet_group_id  = aws_dms_replication_subnet_group.dms-subnet-group.id
  vpc_security_group_ids = [aws_security_group.analytical-to-redshift-sg.id]
  #iam_role_arn = aws_iam_role.dms_role.arn

  # depends_on = [aws_dms_replication_subnet_group.dms_subnet_group]
  depends_on = [
      aws_dms_replication_subnet_group.dms-subnet-group,
      aws_iam_role.dms_role
      ]
  # depends_on = [aws_iam_role.dms_role]

}


resource "aws_dms_endpoint" "thx-analytical-postgres" {
  endpoint_id         = "thx-analytical-postgres"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  # username                    = "postgres"
  # password                    = "Admin123#45"
  username                    = var.THX_ANALYTICAL_POSTGRES_DB_USERNAME
  password                    = var.THX_ANALYTICAL_POSTGRES_DB_PASSWORD
  server_name                 = var.thx-analytical-postgres_rds_endpoint
  port                        = var.thx-analytical-postgres_DB_Port
  database_name               = var.thx-analytical-postgres_DB_Name
  #extra_connection_attributes = "your_extra_connection_attributes"

  # depends_on = [aws_dms_replication_instance.analytical-to-redshift]
}


resource "aws_dms_endpoint" "memo2-dev-prod" {
  endpoint_id         = "memo2-dev-prod"
  endpoint_type               = "source"
  engine_name                 = "postgres"
  # username                    = "postgres"
  # password                    = "Admin123#45"
  username                    = var.MEMO2_DEV_PROD_POSTGRES_DB_USERNAME
  password                    = var.MEMO2_DEV_PROD_POSTGRES_DB_PASSWORD
  server_name                 = var.memo2-dev-prod-postgres_rds_endpoint
  port                        = var.memo2-dev-prod-postgres_DB_Port
  database_name               = var.memo2-dev-prod-postgres_DB_Name
  #extra_connection_attributes = "your_extra_connection_attributes"

  # depends_on = [aws_dms_replication_instance.analytical-to-redshift]
}



# this is mobile-to-analytical dms replication instance
resource "aws_dms_replication_instance" "mobile-to-analytical" {
  allocated_storage    = 20
  engine_version       = "3.5.1"
  publicly_accessible = true
  replication_instance_class = var.replication_instance_class
  replication_instance_id = var.mobile_to_analytical
  replication_subnet_group_id  = aws_dms_replication_subnet_group.dms-subnet-group.id
  vpc_security_group_ids = [aws_security_group.mobile-to-analytical-sg.id]
  #iam_role_arn = aws_iam_role.dms_role.arn

  # depends_on = [aws_dms_replication_subnet_group.dms_subnet_group]
  depends_on = [
      aws_dms_replication_subnet_group.dms-subnet-group,
      aws_iam_role.dms_role
      ]
  # depends_on = [aws_iam_role.dms_role]

}

























# redshift function start
resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "redshift-subnet-group"
  subnet_ids = [ 
    "subnet-0e05e37b8371a855f",
    "subnet-0e85c6abddebe857a", 
    "subnet-02b080ed290bc7523"
   ]
}

# Redshift instance Security Group
resource "aws_security_group" "redshift_security_group" {
  name        = "redshift-security-group-sg"
  description = "memo2 dms replication sg port"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Allow Port 5439"
    from_port        = 5439
    to_port          = 5439
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  ingress {
    description      = "Allow Port 5432"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow all IPs and Port for outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "memo2-redshift-sg-port"
  }
}

resource "aws_iam_role" "dms_access_for_endpoint" {
  name = "dms-access-for-endpoint"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "1",
        Effect    = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      },
      {
        Sid       = "2",
        Effect    = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_amazon_dms_redshift_s3_role" {
  name       = "attach_amazon_dms_redshift_s3_role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSRedshiftS3Role"
  roles      = [aws_iam_role.dms_access_for_endpoint.name]
}


resource "aws_redshift_cluster" "thx-analytical-redshift" {
  cluster_identifier = "redshift-cluster"
  database_name      = var.thx-analytical-redshift_database_name
  master_username    = var.THX_ANALYTICAL_REDSHIFT_MASTER_USERNAME
  master_password    = var.THX_ANALYTICAL_REDSHIFT_MASTER_PASSWORD
  node_type          = var.thx-analytical-redshift_node_type
  cluster_type       = var.thx-analytical-redshift_cluster_type
  number_of_nodes    = var.thx-analytical-redshift_number_of_nodes
  vpc_security_group_ids = [aws_security_group.redshift_security_group.id]
  iam_roles         = [aws_iam_role.dms_access_for_endpoint.arn]
  #final_snapshot_identifier = "no-snapshot"
  skip_final_snapshot = true
  cluster_subnet_group_name  = aws_redshift_subnet_group.redshift_subnet_group.name

  depends_on = [aws_redshift_subnet_group.redshift_subnet_group]
}



# FOr endpoint section


# Target endpoint (AWS Redshift)
resource "aws_dms_endpoint" "thx-analytical-redshift" {
  endpoint_id                 = "thx-analytical-redshift"
  endpoint_type               = "target"
  engine_name                 = "redshift"
  # username                    = "redshiftdb"
  # password                    = "Admin1234"
  username                    = var.THX_ANALYTICAL_REDSHIFT_MASTER_USERNAME
  password                    = var.THX_ANALYTICAL_REDSHIFT_MASTER_PASSWORD
  #server_name                = "test-redshift-cluster.cnie0hy9uejp.eu-west-2.redshift.amazonaws.com"
  #server_name                = aws_redshift_cluster.redshift-cluster.endpoint
  server_name                 =join(".", slice(split(":", aws_redshift_cluster.thx-analytical-redshift.endpoint), 0, 1))
  port                        = var.thx-analytical-redshift_port
  database_name               = var.thx-analytical-redshift_database_name
  #extra_connection_attributes = "your_extra_connection_attributes"


  #depends_on = [aws_redshift_cluster.redshift-cluster]
  depends_on = [
    aws_redshift_cluster.thx-analytical-redshift
  ]

}



resource "aws_dms_endpoint" "memo2-analytics-prod" {
  endpoint_id         = "memo2-analytics-prod"
  endpoint_type               = "target"
  engine_name                 = "postgres"
  # username                    = "postgres"
  # password                    = "Admin123#45"
  username                    = var.MEMO2_DEV_PROD_POSTGRES_DB_USERNAME
  password                    = var.MEMO2_DEV_PROD_POSTGRES_DB_PASSWORD
  server_name                 = var.memo2-analytics-prod-postgres_rds_endpoint
  port                        = var.memo2-dev-prod-postgres_DB_Port
  database_name               = var.memo2-dev-prod-postgres_DB_Name
  #extra_connection_attributes = "your_extra_connection_attributes"

  # depends_on = [aws_dms_replication_instance.analytical-to-redshift]
}





















#migration task start

resource "aws_iam_role" "dms_cloudwatch_role" {
  name = "dms-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dms_cloudwatch_policy" {
  name        = "dms-cloudwatch-policy"
  description = "Policy to allow DMS to publish CloudWatch logs"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogStream",
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "logs:PutLogEvents",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_dms_cloudwatch_policy" {
  # name       = "attach_dms_cloudwatch_policy" 
  name       = "attach_dms_cloudwatch_policy-111111111111111111111111111111111" 
  policy_arn = aws_iam_policy.dms_cloudwatch_policy.arn
  roles      = [aws_iam_role.dms_cloudwatch_role.name]
}

resource "aws_dms_replication_task" "db-replication-events-to-redshift" {
  replication_task_id      = "db-replication-events-to-redshift"
  replication_instance_arn = aws_dms_replication_instance.analytical-to-redshift.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.thx-analytical-postgres.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.thx-analytical-redshift.endpoint_arn

  migration_type           = "full-load-and-cdc"

  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

  lifecycle {
    ignore_changes = [replication_task_settings]
  }
  provisioner "local-exec" {
  when    = create
  command = "aws dms start-replication-task  --start-replication-task-type reload-target  --replication-task-arn ${aws_dms_replication_task.db-replication-events-to-redshift.replication_task_arn}  --region eu-west-2"
  # You can add environment variables or other settings as needed
  }


}


resource "aws_dms_replication_task" "db-replication-prod-to-redshift-task" {
  replication_task_id      = "db-replication-prod-to-redshift-task"
  replication_instance_arn = aws_dms_replication_instance.analytical-to-redshift.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.memo2-dev-prod.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.thx-analytical-redshift.endpoint_arn

  migration_type           = "full-load-and-cdc"

  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

  lifecycle {
    ignore_changes = [replication_task_settings]
  }
  provisioner "local-exec" {
  when    = create
  command = "aws dms start-replication-task  --start-replication-task-type reload-target  --replication-task-arn ${aws_dms_replication_task.db-replication-prod-to-redshift-task.replication_task_arn}  --region eu-west-2"
  # You can add environment variables or other settings as needed
  }


}



resource "aws_dms_replication_task" "db-replication-prod-to-analytics" {
  replication_task_id      = "db-replication-prod-to-analytics"
  replication_instance_arn = aws_dms_replication_instance.mobile-to-analytical.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.memo2-dev-prod.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.memo2-analytics-prod.endpoint_arn

  migration_type           = "full-load-and-cdc"

  table_mappings            = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\"%\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"

  lifecycle {
    ignore_changes = [replication_task_settings]
  }
  provisioner "local-exec" {
  when    = create
  command = "aws dms start-replication-task  --start-replication-task-type reload-target  --replication-task-arn ${aws_dms_replication_task.db-replication-prod-to-analytics.replication_task_arn}  --region eu-west-2"
  # You can add environment variables or other settings as needed
  }


}