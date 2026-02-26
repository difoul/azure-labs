output "vm-password" {
  value     = random_password.pwd.result
  sensitive = true
}