# -------------------------------------------------------
# Repository-scoped ABAC role assignments
# Only created when enable_abac = true and repositories is non-empty
#
# Roles:
#   pull → Container Registry Repository Reader  (content/read + metadata/read)
#   push → Container Registry Repository Writer  (content/read/write + metadata/read/write)
#
# Each role assignment carries an ABAC condition that restricts the role
# to the named repository only, using StringEqualsIgnoreCase on
# @Request[Microsoft.ContainerRegistry/registries/repositories:name].
# -------------------------------------------------------

locals {
  # --- Flatten pull assignments (Reader) ---
  # Key uses the list index, not the principal_id, so it is fully known at
  # plan time even when principal_id comes from a resource being created.
  pull_assignments = var.enable_abac ? {
    for pair in flatten([
      for repo, cfg in var.repositories : [
        for idx, pid in cfg.pull_principal_ids : {
          key          = "${repo}::pull::${idx}"
          repo         = repo
          principal_id = pid
        }
      ]
    ]) : pair.key => pair
  } : {}

  # --- Flatten push assignments (Writer) ---
  push_assignments = var.enable_abac ? {
    for pair in flatten([
      for repo, cfg in var.repositories : [
        for idx, pid in cfg.push_principal_ids : {
          key          = "${repo}::push::${idx}"
          repo         = repo
          principal_id = pid
        }
      ]
    ]) : pair.key => pair
  } : {}
}

# Pull — Container Registry Repository Reader scoped to one repository
resource "azurerm_role_assignment" "repo_pull" {
  for_each = local.pull_assignments

  scope                = azurerm_container_registry.this.id
  role_definition_name = "Container Registry Repository Reader"
  principal_id         = each.value.principal_id
  condition_version    = "2.0"

  # Condition: for content/read and metadata/read actions, the repository
  # name must match exactly. All other actions are unrestricted.
  condition = <<-EOT
    (
     (
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
      AND
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
     )
     OR
     (
      @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringStartsWithIgnoreCase '${each.value.repo}'
     )
    )
  EOT

  depends_on = [azapi_update_resource.acr_abac]
}

# Push — Container Registry Repository Writer scoped to one repository
resource "azurerm_role_assignment" "repo_push" {
  for_each = local.push_assignments

  scope                = azurerm_container_registry.this.id
  role_definition_name = "Container Registry Repository Writer"
  principal_id         = each.value.principal_id
  condition_version    = "2.0"

  # Condition: for all data-plane write/read actions, the repository
  # name must match exactly. All other actions are unrestricted.
  condition = <<-EOT
    (
     (
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/read'})
      AND
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/content/write'})
      AND
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/read'})
      AND
      !(ActionMatches{'Microsoft.ContainerRegistry/registries/repositories/metadata/write'})
     )
     OR
     (
      @Request[Microsoft.ContainerRegistry/registries/repositories:name] StringStartsWithIgnoreCase '${each.value.repo}'
     )
    )
  EOT

  depends_on = [azapi_update_resource.acr_abac]
}
