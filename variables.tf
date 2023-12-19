variable "region" {
    type        = string
    description = "The AWS region"
}

variable "vpc_name" {
    type        = string
    description = "The name of the VPC"
}

variable "cidr_block" {
    type        = string
    description = "Cidr block of the desired VPC"
}

variable "instance_tenancy" {
    type        = string
    description = "A tenancy option for instances launched into the VPC"
}

variable "enable_dns_support" {
    type        = bool
    description = "Enable/disable DNS support in the VPC"
}

variable "enable_dns_hostnames" {
    type        = bool
    description = "Enable/disable DNS hostnames in the VPC"
}

variable "subnets" {
   type = map
}

variable "route_tables" {
   type = list(any)
}

variable "enable_internet_gateway" {
  type        = bool
  description = "Enable/disable internet gateway in the VPC"
  default     = false
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable/disable nat gateway in the VPC"
  default     = false
}

variable "nat_gw_subnet" {
  type        = string
  description = "Subnet from list of subnets"
  default     = null
}

variable "remove_nacl_allow_all_rule" {
    type        = bool
    description = "Removes the default allow all rule on NACL."
}

variable "nacl_rules" {
   type = map
}

variable "enable_p2p_vpn_vgw" {
    type        = bool
    description = "Enable/disable a point to point VPN on a VPN Gateway"
    default     = false
}

variable "customer_vpn_device_name" {
    type        = string
    description = "A name for the customer gateway device"
    default     = null
}

variable "customer_vpn_gateway_ip" {
    type        = string
    description = "The IPv4 address for the customer gateway device's outside interface"
    default     = null
}

variable "customer_vpn_gateway_bgp_asn" {
    type        = number
    description = "The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)"
    default     = null
}

variable "ike_versions" {
    type        = list(any)
    description = "The IKE version that is permitted"
    default     = null
}

variable "tunnel1_psk" {
    type        = string
    description = "The preshared key of the first VPN tunnel"
    sensitive   = true
    default     = null
}

variable "tunnel2_psk" {
    type        = string
    description = "The preshared key of the second VPN tunnel"
    sensitive   = true
    default     = null
}

variable "phase1_encryption_algorithms" {
    type        = list(any)
    description = "List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16"
    default     = null
}

variable "phase1_dh_group_numbers" {
    type        = list(any)
    description = "List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24"
    default     = null
}

variable "phase1_integrity_algorithms" {
    type        = list(any)
    description = "One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512"
    default     = null
}

variable "phase1_lifetime_seconds" {
    type        = number
    description = "The lifetime for phase 1 of the IKE negotiation for the first VPN tunnel, in seconds. Valid value is between 900 and 28800"
    default     = null
}

variable "phase2_dh_group_numbers" {
    type        = list(any)
    description = "List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations"
    default     = null
}

variable "phase2_encryption_algorithms" {
    type        = list(any)
    description = "List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16"
    default     = null
}

variable "phase2_integrity_algorithms" {
    type        = list(any)
    description = "List of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512"
    default     = null
}

variable "phase2_lifetime_seconds" {
    type        = number
    description = "The lifetime for phase 2 of the IKE negotiation for the first VPN tunnel, in seconds. Valid value is between 900 and 3600"
    default     = null
}

variable "vpn_local_network" {
    type        = string
    description = "The local VPN network in CIDR format."
    default     = null
}

variable "enable_transit_gateway" {
    type        = bool
    description = "Enable/disable a transit gateway."
    default     = false
}

variable "transit_gateway_amazon_side_asn" {
    type        = number
    description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session. The range is 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs."
    default     = null
}

variable "transit_gateway_auto_accept_shared_attachments" {
    type        = string
    description = "Whether resource attachment requests are automatically accepted."
    default     = null
}

variable "transit_gateway_default_route_table_association" {
    type        = string
    description = "Whether resource attachments are automatically associated with the default association route table."
    default     = null
}

variable "transit_gateway_default_route_table_propagation" {
    type        = string
    description = "Whether resource attachments automatically propagate routes to the default propagation route table."
    default     = null
}

variable "transit_gateway_dns_support" {
    type        = string
    description = "Whether DNS support is enabled."
    default     = null
}

variable "transit_gateway_cidr_blocks" {
    type        = list(any)
    description = "One or more IPv4 or IPv6 CIDR blocks for the transit gateway. Must be a size /24 CIDR block or larger for IPv4, or a size /64 CIDR block or larger for IPv6."
    default     = null
}

variable "transit_gateway_vpc_attachment_to_public_subnets" {
    type        = bool
    description = "If enabled, the transit gateway VPC attachments will be on public subnets."
    default     = true
}

variable "transit_gateway_vpc_attachment_to_private_subnets" {
    type        = bool
    description = "If enabled, the transit gateway VPC attachments will be on private subnets."
    default     = false
}

variable "transit_gateway_vpc_subnet_tier" {
    type        = string
    description = "The subnet Tier to use for transit gateway VPC attchments"
    default     = null
}

variable "enable_p2p_vpn_tgw" {
    type        = bool
    description = "Enable/disable a point to point VPN on a Transit Gateway"
    default     = false
}

variable "enable_spoke_transit_gateway_vpc_attachment" {
    type        = bool
    description = "Enables a spoke VPC attachment to a Transit Gateway"
    default     = false
}

variable "hub_transit_gw_id" {
    type        = string
    description = "The target Transit Gateway ID for the Spoke VPC to connect to."
    default     = null
}

variable "tags" {
    type        = map
    description = "A map of tags."
    default     = null
}

