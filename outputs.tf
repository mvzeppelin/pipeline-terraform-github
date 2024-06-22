output "vm-aws-ip" {
  value = aws_instance.vm.public_ip
}

output "vm-azure-ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}