variable "public_subnet_ids" {
  description = "The public subnet ids used by ecs"
  type        = "list"
}

variable "vpc_id" {
  description = "The id of the vpc"
  type        = "string"
}
