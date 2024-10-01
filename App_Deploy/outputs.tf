output "public_ip" {
  value = "Public IP=${aws_instance.app_server.public_ip}"
}

output "public_dns" {
  value = "Public DNS=http://${aws_instance.app_server.public_dns}/"
}
