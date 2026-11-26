mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "two_az_database_network" {
  command = plan
  module {
    source = "./modules/networking"
  }
  variables {
    name                   = "fastapi-test"
    availability_zones     = ["ap-southeast-1a", "ap-southeast-1b"]
    vpc_cidr               = "10.40.0.0/16"
    public_subnet_count    = 2
    private_subnet_count   = 2
    nat_gateway_count      = 2
    public_subnet_newbits  = 8
    private_subnet_newbits = 8
    public_subnet_offset   = 0
    private_subnet_offset  = 10
  }

  assert {
    condition = (
      tolist([for subnet in aws_subnet.public : subnet.availability_zone]) == var.availability_zones &&
      tolist([for subnet in aws_subnet.private : subnet.availability_zone]) == var.availability_zones
    )
    error_message = "The VPC must have public and private subnets in exactly two AZs."
  }
}

run "multi_az_postgres_instance" {
  command = plan
  module {
    source = "./modules/database"
  }
  variables {
    name                      = "fastapi-test"
    subnet_ids                = ["subnet-a", "subnet-b"]
    security_group_id         = "sg-db"
    engine                    = "postgres"
    engine_version            = "17.1"
    instance_class            = "db.m6gd.large"
    database_name             = "demodb"
    username                  = "appadmin"
    allocated_storage         = 100
    storage_type              = "io1"
    iops                      = 1000
    storage_encrypted         = true
    backup_retention_period   = 7
    deletion_protection       = true
    skip_final_snapshot       = false
    final_snapshot_identifier = "fastapi-test-final"
  }

  assert {
    condition = (
      aws_db_instance.this.engine == "postgres" &&
      aws_db_instance.this.multi_az &&
      !aws_db_instance.this.publicly_accessible &&
      aws_db_instance.this.manage_master_user_password &&
      aws_db_instance.this.storage_encrypted &&
      aws_db_instance.this.deletion_protection
    )
    error_message = "The database must be an encrypted, private Multi-AZ PostgreSQL instance using an RDS-managed secret."
  }
}
