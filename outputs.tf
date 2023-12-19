output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.vpc.cidr_block
  description = "The CIDR block of the VPC"
}

output "vpc_arn" {
  value       = aws_vpc.vpc.arn
  description = "The ARN of the VPC"
}

output "vpc_main_route_table_id" {
  value       = aws_vpc.vpc.main_route_table_id
  description = "The ID of the main route table associated with this VPC"
}

output "vpc_default_route_table_id" {
  value       = aws_vpc.vpc.default_route_table_id
  description = "The ID of the default route table associated with this VPC"
}

output "vpc_default_network_acl_id" {
  value       = aws_vpc.vpc.default_network_acl_id
  description = "The ID of the network ACL created by default on VPC creation"
}

output "vpc_default_security_group_id" {
  value       = aws_vpc.vpc.default_security_group_id
  description = "The ID of the security group created by default on VPC creation"
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.*.id
  description = "The IDs of the internet gateway"
}

output "internet_gateway_arn" {
  value       = aws_internet_gateway.igw.*.id
  description = "The ARN of the internet gateway"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat_gw.*.id
  description = "The IDs of the NAT gateway"
}

output "nat_gateway_arn" {
  value       = aws_nat_gateway.nat_gw.*.id
  description = "The ARN of the NAT gateway"
}

output "route_tables" {
  value       = aws_route_table.route_tables
  description = "The IDs of the route tables"
}

output "customer_gateway_id" {
  value       = aws_customer_gateway.customer_gateway.*.id
  description = "The amazon-assigned ID of the gateway"
}

output "customer_gateway_arn" {
  value       = aws_customer_gateway.customer_gateway.*.arn
  description = "The ARN of the customer gateway"
}

output "vpn_gw_id" {
  value       = aws_vpn_gateway.vpn_gw.*.id
  description = "The ID of the VPN Gateway"
}

output "vpn_gw_arn" {
  value       = aws_vpn_gateway.vpn_gw.*.arn
  description = "Amazon Resource Name (ARN) of the VPN Gateway"
}

output "transit_gateway_arn" {
  value       = aws_ec2_transit_gateway.transit_gateway.*.arn
  description = "EC2 Transit Gateway Amazon Resource Name (ARN)."
}

output "transit_gateway_id" {
  value       = aws_ec2_transit_gateway.transit_gateway.*.id
  description = "EC2 Transit Gateway identifier."
}

output "transit_gateway_association_default_route_table_id" {
  value       = aws_ec2_transit_gateway.transit_gateway.*.association_default_route_table_id
  description = "Identifier of the default association route table."
}
