#!/usr/bin/env bash
# Wires Key Vault and Azure Firewall diagnostic logs into the Log Analytics
# workspace deployed by src/bicep/main.bicep.
#
# Usage: ./connect-diagnostics.sh <resource-group>
set -euo pipefail

RESOURCE_GROUP="${1:?Usage: $0 <resource-group>}"

WORKSPACE_ID=$(az monitor log-analytics workspace list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].id" -o tsv)

VAULT_ID=$(az keyvault list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].id" -o tsv)

FIREWALL_ID=$(az network firewall list \
  --resource-group "$RESOURCE_GROUP" \
  --query "[0].id" -o tsv)

echo "Wiring Key Vault audit logs -> $WORKSPACE_ID"
az monitor diagnostic-settings create \
  --name kv-diagnostics \
  --resource "$VAULT_ID" \
  --workspace "$WORKSPACE_ID" \
  --logs '[{"category": "AuditEvent", "enabled": true}]'

echo "Wiring Azure Firewall traffic logs -> $WORKSPACE_ID"
az monitor diagnostic-settings create \
  --name fw-diagnostics \
  --resource "$FIREWALL_ID" \
  --workspace "$WORKSPACE_ID" \
  --logs '[
    {"category": "AzureFirewallApplicationRule", "enabled": true},
    {"category": "AzureFirewallNetworkRule", "enabled": true},
    {"category": "AzureFirewallDnsProxy", "enabled": true}
  ]'

echo "Done. Both resources now send logs to the workspace — see src/queries/ for how to use them."
