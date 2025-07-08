locals {
  terraform_version  = chomp(file(".terraform-version"))
  terragrunt_version = chomp(file(".terragrunt-version"))
  env_type_vars      = read_terragrunt_config(find_in_parent_folders("env_type.hcl"))
  env_instance_vars  = read_terragrunt_config(find_in_parent_folders("env_instance.hcl"))
}

remote_state {
  backend = "azurerm"
  generate = {
    path       = "tg_auto_backend.tf"
    if_exists  = "overwrite_terragrunt"
  }
  config = {
    resource_group_name  = local.env_instance_vars.locals.remote_state.resource_group_name
    storage_account_name = local.env_instance_vars.locals.remote_state.storage_account_name
    subscription_id      = local.env_instance_vars.locals.remote_state.subscription_id
    tenant_id            = local.env_instance_vars.locals.remote_state.tenant_id
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    required_var_files = [
      find_in_parent_folders("env_type.tfvars"),
      find_in_parent_folders("env_region.tfvars"),
      find_in_parent_folders("cors_addresses.tfvars"),
      find_in_parent_folders("env_instance.tfvars"),
      find_in_parent_folders("global.tfvars"),
    ]
  }
}

terraform_version_constraint     = local.terraform_version
terragrunt_version_constraint    = ">= ${local.terragrunt_version}"

generate "tfenv" {
  path              = ".terraform-version"
  if_exists         = "overwrite"
  disable_signature = true

  contents = <<EOF
${local.terraform_version}
EOF
}

generate "provider" {
  path            = "tg_auto_provider.tf"
  if_exists       = "overwrite_terragrunt"
  contents        = <<EOF
provider "azurerm" {
  subscription_id      = "${local.env_instance_vars.locals.providers.subscription_id}"
  tenant_id            = "${local.env_instance_vars.locals.providers.tenant_id}"
  features {
    application_insights {
      disable_generated_rule = true
    }
    key_vault {
      purge_soft_delete_on_destroy = "${local.env_type_vars.locals.provider_features.purge_soft_delete_on_destroy}"
    }
  }
}
}

provider "azurerm" {
  alias           = "saas-shared"
  tenant_id       = "${local.env_instance_vars.locals.providers.tenant_id}"
  subscription_id = "${local.env_instance_vars.locals.providers.subscription_id}"
  features {}
}

provider "azapi" {}
provider "azuread" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.117.1"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.3.0"
    }
  }
EOF
}
