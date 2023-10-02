# Introduction

Within any Azure Cloud infrastructure, there are a lot of dependencies between resources.
For example: to create a Virtual Machine, first its required to create networking, create a resource greoup, create a network adapter, disks, and then the VM itself.

On the different levels of abstraction, there are different dependencies. To finally deploy the infrastructure it is required to deploy all resources in the correct order.
The ideal situation for Terraform is to deploy the whole environment with all dependencies at once. In that case, it is easy to set all dependencies within code and all resources will be deployed in the correct sequence.
This approach works well in small environments where there is still possible to have control over deploying and updating resources during a single deployment without risks.

However, when the environment is complex there are a lot of shared resources that shouldn't be affected or updated when it is required to add some new workload or some new piece of the infrastructure.
Additionally, it is hard to keep control over a huge Terraform plan of hundred or thousand parameters that appears there.

For this reason, the deployment of the complex infrastructure is split into several parts which are executed independently.
Therefore with this approach, it is important to deploy all these independent pieces in the correct order like core Resource Groups, then shared Networking, then Firewalls, Gateways, and so on.

# Deployment order

The Azure Landing Zone has a big amount of resources that are possible to deploy. But at the same time, these resources are dependent of each other. That is why we have to follow the next deployment order:

| Deployment priority code | Scope | Description |
|--|--|--|
| 000 | KeyVault, Storage Account | Initial resources to set up Terraform(ARM templates) |
| 001 | Management groups | - |
| 002 | Subscriptions | - |
| 005 | Resource Groups | - |
| 010 | Log Analytics Workspace | - |
| 015 | Advisor, Defender, Activity Log | Can be deployed in parallel |
| 020 | Automation Account, Netwatcher | Can be deployed in parallel |
| 025 | ASG, Public IP, VNET | Can be deployed in parallel |
| 030 | NSG, PrivateDNS, PublicDNS, Virtual gateways | Can be deployed in parallel |
| 035 | KeyVault, Storage Account, VNET Peerings | Can be deployed in parallel |
| 040 | Firewall Policy, LoadBalancer | Can be deployed in parallel |
| 045 | AzureFW/NVA, vWAN | Can be deployed in parallel |
| 050 | Bastion, UDRs, Routeserver, Shared Image Gallery | Can be deployed in parallel |
| 055 | Application Gateway, Recovery Vault Services, VM(need to be revised) | Can be deployed in parallel |
| 060 | VMs(with no DB or other dependency, eg.: AD servers) | - |
| 065+ | Other solutions | - |
