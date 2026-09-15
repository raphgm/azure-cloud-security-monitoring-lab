#!/usr/bin/env bash
# Enables Microsoft Defender for Cloud plans, per workload type.
#
# Edit the PLANS array below to match what's actually deployed in your
# subscription — enabling every plan on a subscription that only runs
# VMs and Storage is spend with zero protection benefit.
set -euo pipefail

PLANS=(
  "VirtualMachines"
  "StorageAccounts"
  "KeyVaults"
)

echo "Checking currently deployed resource types..."
az resource list --query "[].type" -o tsv | sort -u

for plan in "${PLANS[@]}"; do
  echo "Enabling Defender plan: $plan"
  az security pricing create --name "$plan" --tier Standard
done

echo "Done. Review Secure Score at: Defender for Cloud > Overview in the Azure portal."
