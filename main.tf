locals {
  routes = {
    igw = {
      "0.0.0.0/0" = aws_internet_gateway.igw.*.id
    }
    nat_gw = {
      "0.0.0.0/0" = aws_nat_gateway.nat_gw.*.id
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = merge(var.tags, {
    Name               = var.vpc_name
  })
}

resource "aws_subnet" "public_subnets" {
  for_each                = var.subnets.public
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value["cidr_block"]
  availability_zone       = each.value["availability_zone"]
  map_public_ip_on_launch = each.value["map_public_ip_on_launch"]
  tags                    = merge(var.tags, each.value["tags"], {
    Name                  = each.key
  })
}

resource "aws_subnet" "private_subnets" {
  for_each                = var.subnets.private
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value["cidr_block"]
  availability_zone       = each.value["availability_zone"]
  map_public_ip_on_launch = each.value["map_public_ip_on_launch"]
  tags                    = merge(var.tags, each.value["tags"], {
    Name                              = each.key
  })
}

resource "aws_internet_gateway" "igw" {
  count  = var.enable_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, {
    Name = "${var.vpc_name}-IGW"
  })
}

resource "aws_eip" "nat_gw_eip" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags          = merge(var.tags, {
    Name        = "${var.vpc_name}-NATGW-EIP"
  })
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gateway ? 1 : 0
  depends_on    = [aws_internet_gateway.igw]
  allocation_id = aws_eip.nat_gw_eip[0].id
  subnet_id     = aws_subnet.public_subnets[var.nat_gw_subnet].id
  tags          = merge(var.tags, {
    Name        = "${var.vpc_name}-NATGW"
  })
}

resource "aws_route_table" "route_tables" {
  for_each = toset(var.route_tables)
  vpc_id   = aws_vpc.vpc.id
  tags     = merge(var.tags, {
    Name   = "${var.vpc_name}-${each.key}-RT"
  })
}

resource "aws_route" "aws_route_igw" {
  route_table_id         = aws_route_table.route_tables[var.route_tables[0]].id
  for_each               = var.enable_internet_gateway ? local.routes.igw : {}
  destination_cidr_block = each.key
  gateway_id             = each.value[0]
}

resource "aws_route" "aws_route_nat_gw" {
  route_table_id         = aws_route_table.route_tables[var.route_tables[1]].id
  for_each               = var.enable_nat_gateway ? local.routes.nat_gw : {}
  destination_cidr_block = each.key
  nat_gateway_id             = each.value[0]
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_tables[var.route_tables[0]].id
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_tables[var.route_tables[1]].id
}

resource "aws_network_acl_rule" "default_nacl_rules" {
  for_each       = var.nacl_rules
  network_acl_id = aws_vpc.vpc.default_network_acl_id
  rule_number    = each.value["rule_number"]
  egress         = each.value["egress"]
  protocol       = each.value["protocol"]
  rule_action    = each.value["rule_action"]
  cidr_block     = each.value["cidr_block"]
  from_port      = each.value["from_port"]
  to_port        = each.value["to_port"]
}

resource "null_resource" "remove_default_nacl_rule" {
  count       = var.remove_nacl_allow_all_rule ? 1 : 0
  depends_on  = [aws_vpc.vpc]

  provisioner "local-exec" {
    command = "aws ec2 delete-network-acl-entry --network-acl-id ${aws_vpc.vpc.default_network_acl_id} --ingress --rule-number 100"
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  count       = var.enable_p2p_vpn_vgw  || var.enable_p2p_vpn_tgw ? 1 : 0
  device_name = var.customer_vpn_device_name
  ip_address  = var.customer_vpn_gateway_ip
  bgp_asn     = var.customer_vpn_gateway_bgp_asn
  type        = "ipsec.1"
  tags        = merge(var.tags, {
    Name      = "${var.customer_vpn_device_name}-CGW"
  })
}

resource "aws_vpn_gateway" "vpn_gw" {
  count  = var.enable_p2p_vpn_vgw ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, {
    Name = "${var.customer_vpn_device_name}-VPN-GW"
  })
}

resource "aws_vpn_connection" "vgw_vpn_connection" {
  count                                = var.enable_p2p_vpn_vgw ? 1 : 0
  vpn_gateway_id                       = aws_vpn_gateway.vpn_gw[0].id
  customer_gateway_id                  = aws_customer_gateway.customer_gateway[0].id
  type                                 = "ipsec.1"
  static_routes_only                   = true
  tunnel1_ike_versions                 = var.ike_versions
  tunnel2_ike_versions                 = var.ike_versions
  tunnel1_preshared_key                = var.tunnel1_psk
  tunnel2_preshared_key                = var.tunnel2_psk
  tunnel1_phase1_encryption_algorithms = var.phase1_encryption_algorithms
  tunnel2_phase1_encryption_algorithms = var.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.phase1_integrity_algorithms
  tunnel2_phase1_integrity_algorithms  = var.phase1_integrity_algorithms
  tunnel1_phase1_dh_group_numbers      = var.phase1_dh_group_numbers
  tunnel2_phase1_dh_group_numbers      = var.phase1_dh_group_numbers
  tunnel1_phase1_lifetime_seconds      = var.phase1_lifetime_seconds
  tunnel2_phase1_lifetime_seconds      = var.phase1_lifetime_seconds
  tunnel1_phase2_encryption_algorithms = var.phase2_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = var.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = var.phase2_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = var.phase2_integrity_algorithms
  tunnel1_phase2_dh_group_numbers      = var.phase2_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = var.phase2_dh_group_numbers
  tunnel1_phase2_lifetime_seconds      = var.phase2_lifetime_seconds
  tunnel2_phase2_lifetime_seconds      = var.phase2_lifetime_seconds
}

resource "aws_vpn_connection" "tgw_vpn_connection" {
  count                                = var.enable_p2p_vpn_tgw ? 1 : 0
  transit_gateway_id                   = aws_ec2_transit_gateway.transit_gateway[0].id
  customer_gateway_id                  = aws_customer_gateway.customer_gateway[0].id
  type                                 = "ipsec.1"
  static_routes_only                   = true
  tunnel1_ike_versions                 = var.ike_versions
  tunnel2_ike_versions                 = var.ike_versions
  tunnel1_preshared_key                = var.tunnel1_psk
  tunnel2_preshared_key                = var.tunnel2_psk
  tunnel1_phase1_encryption_algorithms = var.phase1_encryption_algorithms
  tunnel2_phase1_encryption_algorithms = var.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.phase1_integrity_algorithms
  tunnel2_phase1_integrity_algorithms  = var.phase1_integrity_algorithms
  tunnel1_phase1_dh_group_numbers      = var.phase1_dh_group_numbers
  tunnel2_phase1_dh_group_numbers      = var.phase1_dh_group_numbers
  tunnel1_phase1_lifetime_seconds      = var.phase1_lifetime_seconds
  tunnel2_phase1_lifetime_seconds      = var.phase1_lifetime_seconds
  tunnel1_phase2_encryption_algorithms = var.phase2_encryption_algorithms
  tunnel2_phase2_encryption_algorithms = var.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = var.phase2_integrity_algorithms
  tunnel2_phase2_integrity_algorithms  = var.phase2_integrity_algorithms
  tunnel1_phase2_dh_group_numbers      = var.phase2_dh_group_numbers
  tunnel2_phase2_dh_group_numbers      = var.phase2_dh_group_numbers
  tunnel1_phase2_lifetime_seconds      = var.phase2_lifetime_seconds
  tunnel2_phase2_lifetime_seconds      = var.phase2_lifetime_seconds
}

resource "aws_route" "vpn_routes" {
  count                     = var.enable_p2p_vpn_vgw ? length(var.route_tables) : 0
  route_table_id            = aws_route_table.route_tables[var.route_tables[count.index]].id
  gateway_id                = aws_vpn_gateway.vpn_gw[0].id
  destination_cidr_block    = var.vpn_local_network
}

resource "aws_ec2_transit_gateway" "transit_gateway" {
  count                           = var.enable_transit_gateway ? 1 : 0
  amazon_side_asn                 = var.transit_gateway_amazon_side_asn
  auto_accept_shared_attachments  = var.transit_gateway_auto_accept_shared_attachments
  default_route_table_association = var.transit_gateway_default_route_table_association
  default_route_table_propagation = var.transit_gateway_default_route_table_propagation
  dns_support                     = var.transit_gateway_dns_support
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks
  tags   = merge(var.tags, {
    Name = "Transit-Gateway"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "transit_gateway_vpc_attachment" {
  count              = var.enable_transit_gateway ? 1 : 0
  subnet_ids         = data.aws_subnets.transit_subnets[0].ids
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway[0].id
  vpc_id             = aws_vpc.vpc.id
}

resource "aws_ec2_transit_gateway_route" "transit_gateway_vpn_route" {
  count                          = var.enable_p2p_vpn_tgw ? 1 : 0
  destination_cidr_block         = var.vpn_local_network
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.transit_gateway_vpn_attachment[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway[0].association_default_route_table_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_vpc_attachment" {
  count              = var.enable_spoke_transit_gateway_vpc_attachment ? 1 : 0
  subnet_ids         = data.aws_subnets.spoke_subnets[0].ids
  transit_gateway_id = var.hub_transit_gw_id
  vpc_id             = aws_vpc.vpc.id
}

resource "aws_route" "spoke_routes" {
  count                     = var.enable_spoke_transit_gateway_vpc_attachment ? length(var.route_tables) : 0
  route_table_id            = aws_route_table.route_tables[var.route_tables[count.index]].id
  transit_gateway_id        = var.hub_transit_gw_id
  destination_cidr_block    = var.vpn_local_network
}
