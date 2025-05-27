variable "host_os" {
  type    = string
  default = "windows"
}

variable "env" {
  description = "Deployment environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "allowed_ips" {
  type    = list(string)
  default = ["181.51.32.104/32"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet configurations"
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
  description = "Private subnet configurations"
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
    db_name  = string
  })
  default = {
    username = "devops"
    password = "devops123"
    db_name  = "demo1_db"
  }
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "repo_url" {
  description = "URL of the Git repository to clone."
  type        = string
  default     = "https://github.com/icb557/ProPruebas.git"
}

variable "local_propruebas_project_root_windows" {
  description = "Local absolute path to the root of the ProPruebas project on Windows (parent of FrontEnd and BackEnd folders)."
  type        = string
  default     = "../ProPruebas"
}

variable "local_ssh_private_key_path_windows" {
  description = "Path to the local SSH private key on Windows for SCP."
  type        = string
  default     = "C:/Users/Usuario/.ssh/pro_pruebas"
}

variable "app_secret_key" {
  description = "A strong secret key for the application (e.g., for JWTs)."
  type        = string
  default     = "juan"
  sensitive   = true
}

variable "app_cors_origin" {
  description = "cors origin for the app"
  type        = string
  default     = "http://10.0.0.100"
}