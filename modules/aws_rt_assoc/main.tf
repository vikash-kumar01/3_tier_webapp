resource "aws_route_table_association" "rtassoc" {
  subnet_id      = var.subnet_id
  route_table_id = var.public_rt_id
}

