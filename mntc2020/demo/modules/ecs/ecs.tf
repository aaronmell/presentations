data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "minecraft_log_group" {
  name = "minecraft/log-group"

  tags {
    Name = "minecraft-log-group"
  }
}

resource "aws_iam_role" "minecraft_execution_role" {
  name = "minecraft-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "minecraft_execution_role_policy" {
  name = "minecraft-execution-role-policy"
  role = "${aws_iam_role.minecraft_execution_role.id}"

  policy = <<EOF
{
  "Statement": [
    {
      "Action": [ "ecr:GetAuthorizationToken" ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.minecraft_log_group.arn}",
      "Effect": "Allow"
    }        
  ]
}
EOF
}

resource "aws_iam_role" "minecraft_task_role" {
  name = "minecraft-task-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "minecraft_task_role_policy" {
  name = "minecraft-task-role-policy"
  role = "${aws_iam_role.minecraft_task_role.id}"

  policy = <<EOF
{
    "Statement": [   
      {
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": "${aws_cloudwatch_log_group.minecraft_log_group.arn}",
        "Effect": "Allow"
      }
    ]
}
EOF
}

resource "aws_ecs_task_definition" "minecraft_demo" {
  family                   = "minecraft_demo"
  execution_role_arn       = "${aws_iam_role.minecraft_execution_role.arn}"
  network_mode             = "awsvpc"
  cpu                      = 4096
  memory                   = 8192
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = "${aws_iam_role.minecraft_task_role.arn}"

  container_definitions = <<EOF
[
  {
    "dnsSearchDomains": [],
    "logConfiguration": {
      "logDriver": "awslogs",
       "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.minecraft_log_group.name}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "minecraft"
      }
    },
    "entryPoint": [],
    "portMappings": [
      {
          "hostPort": 25565,
          "protocol": "tcp",
          "containerPort": 25565
      }],
    "command": [],
    "linuxParameters": null,
    "cpu": 4,
    "environment": [
      {
          "name": "EULA",
          "value": "true"
      },
      {
         "name": "SERVER_PORT",
         "value": "25565"
      }],
    "ulimits": null,
    "dnsServers": [],
    "mountPoints": [],
    "workingDirectory": null,
    "dockerSecurityOptions": [],
    "memory": null,
    "memoryReservation": null,
    "volumesFrom": [],
    "image": "itzg/minecraft-server",
    "disableNetworking": null,
    "healthCheck": null,
    "essential": true,
    "links": [],
    "hostname": null,
    "extraHosts": null,
    "user": null,
    "readonlyRootFilesystem": null,
    "dockerLabels": null,
    "privileged": null,
    "name": "minecraft"
  }
]
EOF
}

resource "aws_ecs_service" "minecraft_demo" {
  name            = "minecraft"
  task_definition = "${aws_ecs_task_definition.minecraft_demo.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.minecraft_demo.id}"

  network_configuration = {
    assign_public_ip = true
    subnets          = ["${var.public_subnet_ids}"]
    security_groups  = ["${aws_security_group.minecraft_demo.id}"]
  }
}

resource "aws_ecs_cluster" "minecraft_demo" {
  name = "minecraft_demo"
}

resource "aws_security_group" "minecraft_demo" {
  name        = "minecraft"
  description = "Allow inbound traffic from the internet"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "minecraft"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
