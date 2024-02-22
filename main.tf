module "vpc" {

  source   = "./modules/aws_vpc"
  vpc_cidr = var.vpc_cidr
  tags = {
    Name = "main-vpc-${var.stackname}-${var.environment}"
    Env  = "${var.environment}"
  }
}


module "public_subnet1" {

  source = "./modules/aws_subnet"

  vpc_id = module.vpc.vpc_id

  subnet_cidr = var.public_subnet_cidr_1
  subnet_az   = var.availability_zones[0]
  enable_public_ip = true
  tags = {

    Name = "frontend-tier1-subnet-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"

  }
}

module "public_subnet2" {

  source = "./modules/aws_subnet"

  vpc_id = module.vpc.vpc_id

  subnet_cidr = var.public_subnet_cidr_2
  subnet_az   = var.availability_zones[1]
  enable_public_ip = true
  tags = {

    Name = "frontend-tier2-subnet-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"

  }
}


module "private_subnet1" {

  source = "./modules/aws_subnet"

  vpc_id = module.vpc.vpc_id

  subnet_cidr = var.private_subnet_cidr_1
  subnet_az   = var.availability_zones[0]
  enable_public_ip = false
  tags = {

    Name = "backend-tier1-subnet-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"

  }
}
module "private_subnet2" {

  source = "./modules/aws_subnet"

  vpc_id = module.vpc.vpc_id

  subnet_cidr = var.private_subnet_cidr_2
  subnet_az   = var.availability_zones[1]
  enable_public_ip = false
  tags = {

    Name = "backend-tier2-subnet-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"

  }
}
module "private_subnet3" {

  source = "./modules/aws_subnet"

  vpc_id = module.vpc.vpc_id

  subnet_cidr = var.private_subnet_cidr_3
  subnet_az   = var.availability_zones[0]
  enable_public_ip = false
  tags = {

    Name = "db-tier1-subnet-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"

  }
}
module "private_subnet4" {

  source = "./modules/aws_subnet"

  vpc_id = module.vpc.vpc_id

  subnet_cidr = var.private_subnet_cidr_4
  subnet_az   = var.availability_zones[1]
  enable_public_ip = false
  tags = {

    Name = "db-tier2-subnet-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"

  }
}

module "internet_gw" {

  source = "./modules/aws_igw"

  vpc_id = module.vpc.vpc_id
  tags = {
    Name = "IGW-main-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"
  }

}


module "public_route_table" {

  source = "./modules/aws_rt"

  vpc_id = module.vpc.vpc_id
  igw_id = module.internet_gw.igw_id
  tags = {
    Name = "PUBLIC-RT-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"
  }

}
module "private_route_table1" {

  source = "./modules/aws_rt"

  vpc_id = module.vpc.vpc_id
  igw_id = module.natgw1.natgw_id
  tags = {
    Name = "Private-RT1-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"
  }

}

module "private_route_table2" {

  source = "./modules/aws_rt"

  vpc_id = module.vpc.vpc_id
  igw_id = module.natgw1.natgw_id
  tags = {
    Name = "Private-RT2-${var.stackname}-${var.environment}"
    ENV  = "${var.environment}"
  }

}


module "RT_ASSOC_1" {

  source = "./modules/aws_rt_assoc"

  subnet_id    = module.public_subnet1.subnet_id
  public_rt_id = module.public_route_table.rt_id

}
module "RT_ASSOC_2" {

  source = "./modules/aws_rt_assoc"

  subnet_id    = module.public_subnet2.subnet_id
  public_rt_id = module.public_route_table.rt_id

}
module "RT_ASSOC_3" {

  source = "./modules/aws_rt_assoc"

  subnet_id    = module.private_subnet1.subnet_id
  public_rt_id = module.private_route_table1.rt_id

}
module "RT_ASSOC_4" {

  source = "./modules/aws_rt_assoc"

  subnet_id    = module.private_subnet3.subnet_id
  public_rt_id = module.private_route_table1.rt_id

}
module "RT_ASSOC_5" {

  source = "./modules/aws_rt_assoc"

  subnet_id    = module.private_subnet2.subnet_id
  public_rt_id = module.private_route_table2.rt_id

}
module "RT_ASSOC_6" {

  source = "./modules/aws_rt_assoc"

  subnet_id    = module.private_subnet4.subnet_id
  public_rt_id = module.private_route_table2.rt_id

}

module "elastic_ip1" {

  source = "./modules/aws_eip"

  tags = {
    Name = "eip1-${var.stackname}-${var.environment}"
  }
}
module "elastic_ip2" {

  source = "./modules/aws_eip"

  tags = {
    Name = "eip2-${var.stackname}-${var.environment}"
  }
}

module "natgw1" {

  source = "./modules/aws_natgw"

  eip_id    = module.elastic_ip1.eip_id
  subnet_id = module.public_subnet1.subnet_id
  tags = {
    Name = "natgw1-${var.stackname}-${var.environment}"
  }
}


module "natgw2" {

  source = "./modules/aws_natgw"

  eip_id    = module.elastic_ip2.eip_id
  subnet_id = module.public_subnet2.subnet_id
  tags = {
    Name = "natgw2-${var.stackname}-${var.environment}"
  }
}


module "launch_code" {

  source = "./modules/aws_lb"

  min_instances    = var.min_instances
  max_instances    = var.max_instances
  desired_capacity = var.desired_capacity
  vpc_id           = module.vpc.vpc_id
  instance_type    = "t2.micro"
  public_subnets   = [module.public_subnet1.subnet_id, module.public_subnet2.subnet_id]
  key_name         = var.key_name
  certificate_arn  = var.certificate_arn
}

output "abl_dbs" {

  value = module.launch_code.web_app_lb_dns_name
}
