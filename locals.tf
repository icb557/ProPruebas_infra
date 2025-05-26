locals {
  my_sg_keys = ["app_server", "cicd_server"]
  my_sgs = {
    app_server  = aws_security_group.demo1_app_server_sg.id
    cicd_server = aws_security_group.demo1_web_server_sg.id
  }
  admins_ips = ["181.51.33.104/32"]
  sg_ip_pairs = {
    for pair in setproduct(local.my_sg_keys, local.admins_ips) :
    "${pair[0]}_${pair[1]}" => { sg_key = pair[0], ip = pair[1] }
  }
  public_subnet_acl_ids = {
    for k, acl in aws_network_acl.demo1_public_sub_acl : k => acl.id
  }
  public_acl_ip_pairs = {
    for pair in setproduct(keys(local.public_subnet_acl_ids), local.admins_ips) :
    "${pair[0]}_${replace(pair[1], "/", "_")}" => {
      acl_key = pair[0]
      acl_id  = local.public_subnet_acl_ids[pair[0]]
      ip      = pair[1]
    }
  }
}