output "web_server_public_ip" {
  value = aws_instance.demo1_web_server1.public_ip
}

output "app_server_public_ip" {
  value = aws_instance.demo1_app_server1.public_ip
}

output "db_instance_endpoint" {
  value = aws_db_instance.demo1_primary_db.endpoint
}