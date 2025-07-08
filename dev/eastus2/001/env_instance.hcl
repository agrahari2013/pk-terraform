locals {
  remote_state = {
    subscription_id     = "bac17140-4441-497d-98ab-773124840802"
    tenant_id           = "e0b560bc-2bf8-446c-afd6-2783dc5130a9"
    resource_group_name = "rg-khushi-tfstate-01"
    storage_account_name = "sakhushitfstate01"
  }
  providers = {
    subscription_id = "bac17140-4441-497d-98ab-773124840802"
    tenant_id       = "e0b560bc-2bf8-446c-afd6-2783dc5130a9"
  }
}