output "web_server_public_ip" {
  value = aws_instance.web-server-instance.public_ip
}

output "web_server_private_ip" {
  value = aws_instance.web-server-instance.private_ip
}

output "app_server_public_ip" {
  value = aws_instance.application-server-instance.public_ip
}
output "app_server_private_ip" {
  value = aws_instance.application-server-instance.private_ip
}

output "db_server_public_ip" {
  value = aws_instance.database-server-instance.public_ip
}

output "db_server_private_ip" {
  value = aws_instance.database-server-instance.private_ip
}
