# 1. Resource Group
provider "azurerm" {
  features {}
}
resource "random_integer" "rand" {
  min = 1000
  max = 9999
}
resource "azurerm_resource_group" "terra" {
  name     = "terra-rg-${random_integer.rand.result}"
  location = "East US"
}
