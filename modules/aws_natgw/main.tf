resource "aws_nat_gateway" "nat" {
  allocation_id = var.eip_id
  subnet_id     = var.subnet_id

  tags = var.tags
}



