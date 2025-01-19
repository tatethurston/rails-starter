resource "aws_ecs_cluster" "this" {
  name = "application-container-cluster"
}

resource "aws_ecs_service" "application_servers" {
  name            = "application-servers"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].name
    container_port   = 80
  }

  network_configuration {
    subnets          = [aws_subnet.us-west-2a.id]
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = false
  }
}

resource "aws_ecs_service" "background_workers" {
  name            = "background-workers"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets          = [aws_subnet.us-west-2a.id]
    assign_public_ip = false
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "rails-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([{
    name  = "rails"
    image = "amazonlinux:2"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])
}

resource "aws_security_group" "this" {
  name        = "rails-sg"
  description = "Allow inbound HTTP and all outbound traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}
