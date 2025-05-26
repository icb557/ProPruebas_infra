variable "host_os" {
  type    = string
  default = "windows"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "allowed_ips" {
  type    = list(string)
  default = ["181.51.32.104/32"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    public_subnet1 = {
      cidr = "10.0.0.0/24"
      az   = "us-east-1a"
    }
    public_subnet2 = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "private_subnets" {
  description = "Map of private subnets configurations"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    private_subnet1 = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1a"
    }
    private_subnet2 = {
      cidr = "10.0.3.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "db_creds" {
  description = "Map of database credentials"
  sensitive   = true
  type = object({
    username = string
    password = string
  })
  default = {
    username = "devops"
    password = "devops123"
  }
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}


