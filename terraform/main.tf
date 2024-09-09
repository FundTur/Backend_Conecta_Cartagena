# Provider block with an AWS provider
provider "aws" {
  region = "us-west-2"
}

# RDS Postgres
resource "aws_db_instance" "postgres_directus_db" {
  identifier_prefix = "postgres_directus_db"
  engine            = "postgres"
  allocated_storage = 20
  instance_class    = "db.t2.micro"
  name              = "directus_db"
  username          = "postgres_directus_db"
  password          = "p0stgr3s_d3c1r4tus_db"
  skip_final_snapshot = true
}

# Directus instance
resource "aws_instance" "directus" {
  ami           = "ami-0b0dcb5067f272e28"
  instance_type = "t3a.micro"
  key_name      = "directus"
}

# Lambda schedule 1day
resource "aws_lambda_function" "openapi_map_prompt" {
  function_name = "lambda_schedule"
  handler       = "lambda_schedule.handler"
  runtime       = "python3.8"
  timeout       = 300
  memory_size   = 512
  filename      = "lambda_schedule.zip"
}

# Lambda registration user 
resource "aws_lambda_function" "reg_user_lambda" {
  function_name = "register_user"
  handler       = "lambda_function.handler"
  runtime       = "python3.8"
  timeout       = 300
  memory_size   = 512
  filename      = "lambda_function.zip"
}
