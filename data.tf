data "aws_subnets" "transit_subnets" {
  depends_on = [aws_subnet.public_subnets, aws_subnet.private_subnets]
  count      = var.enable_p2p_vpn_tgw ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }

  tags = {
    Tier = var.transit_gateway_vpc_subnet_tier
  }
}

data "aws_ec2_transit_gateway_vpn_attachment" "transit_gateway_vpn_attachment" {
  count              = var.enable_p2p_vpn_tgw ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  vpn_connection_id  = aws_vpn_connection.tgw_vpn_connection[0].id
}

data "aws_subnets" "spoke_subnets" {
  depends_on = [aws_subnet.public_subnets, aws_subnet.private_subnets]
  count      = var.enable_spoke_transit_gateway_vpc_attachment ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }

  tags = {
    Tier = var.transit_gateway_vpc_subnet_tier
  }
}
