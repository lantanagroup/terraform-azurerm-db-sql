locals {
  # vCore tiers mapping
  vcore_tiers = {
    GeneralPurpose   = "GP"
    BusinessCritical = "BC"
    Hyperscale       = "HS"
  }

  # Default family for vCore pools
  elastic_pool_vcore_family = try(var.elastic_pool_sku.family, "Gen5")

  # vCore SKU name (only computed for vCore tiers)
  elastic_pool_vcore_sku_name = (
    var.elastic_pool_sku != null && contains(keys(local.vcore_tiers), var.elastic_pool_sku.tier)
  ) ? format("%s_%s", local.vcore_tiers[var.elastic_pool_sku.tier], local.elastic_pool_vcore_family) : null

  # DTU SKU name (only used for DTU tiers)
  elastic_pool_dtu_sku_name = (
    var.elastic_pool_sku != null && !contains(keys(local.vcore_tiers), var.elastic_pool_sku.tier)
  ) ? format("%sPool", var.elastic_pool_sku.tier) : null

  # Final elastic pool SKU object
  elastic_pool_sku = var.elastic_pool_sku != null ? {
    name     = contains(keys(local.vcore_tiers), var.elastic_pool_sku.tier) ? local.elastic_pool_vcore_sku_name : local.elastic_pool_dtu_sku_name
    capacity = var.elastic_pool_sku.capacity
    tier     = var.elastic_pool_sku.tier
    family   = contains(keys(local.vcore_tiers), var.elastic_pool_sku.tier) ? local.elastic_pool_vcore_family : null
  } : null

  allowed_subnets = [
    for id in var.allowed_subnets_ids : {
      name      = split("/", id)[10]
      subnet_id = id
    }
  ]

  databases_users = var.create_databases_users ? [
    for db in var.databases : {
      username = format("%s_user", replace(db.name, "-", "_"))
      database = db.name
      roles    = ["db_owner"]
    }
  ] : []

  standard_allowed_create_mode = {
    "a" = "Default"
    "b" = "Copy"
    "c" = "Secondary"
    "d" = "PointInTimeRestore"
    "e" = "Restore"
    "f" = "Recovery"
    "g" = "RestoreExternalBackup"
    "h" = "RestoreExternalBackup"
    "i" = "RestoreLongTermRetentionBackup"
    "j" = "OnlineSecondary"
  }

  datawarehouse_allowed_create_mode = {
    "a" = "Default"
    "b" = "PointInTimeRestore"
    "c" = "Restore"
    "d" = "Recovery"
    "e" = "RestoreExternalBackup"
    "f" = "RestoreExternalBackup"
    "g" = "OnlineSecondary"
  }
}
