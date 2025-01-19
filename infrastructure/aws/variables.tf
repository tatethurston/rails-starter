variable "vpc_id" {
  description = "The ID of the existing global VPC (cost savings)"
  type        = string
  default     = "vpc-4a39622f"
}

variable "subnet_id" {
  description = "The ID of the existing global subnet (cost savings)"
  type        = string
  default     = "subnet-381a335d"
}

# variable "load_balancer_arn" {
#   description = "The ARN of the existing global load balancer (cost savings)"
#   type        = string
#   default     = "arn:aws:elasticloadbalancing:us-west-2:170683628345:loadbalancer/app/global-lb/a689bf29206c533c"
# }
