terraform {
  backend "azurerm" {
    use_azuread_auth     = true
    storage_account_name = "ter20572"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

