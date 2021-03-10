
# WVD AIO
Deploys a self-contained WVD environment with a hosted domain controller.



## Active Directory Configuration
You can configure the environment with AD as either the source or target for identities.
## Active Directory as the authoritive source
This is the simplest scenario to cater for.
- Use the hosted domain the authoritive domain, or
- Connect it to your existing AD as a resource domain with an external trust.
- **Password hash synchronization is not required for either of these scenarios.**

When choosing to use the domain at the authoritive source for identities one must install and configure AADConnect.  


![AADConnect](https://docs.microsoft.com/it-it/microsoft-365/education/deploy/images/aad-connect-and-adfs.png)
## External Directory as the authoritive source
In this scenario one would use an external HR system (Workday, etc.) as the identity source and OKTA for provisioning & entitlement.  

**Password synchronization is required for this scenario.**
1. Add the managed domain as a directory to OKTA (ensuring it's NOT configured as a profile source) 
2. Provision user accounts to the managed domain as usual.  
3. Use the Office 365 connector to provision those same users to AAD
4. Use push groups to grant access to to the WVD service
5. Assign access to the WVD application group to the push group created by OKTA

## To deploy the environment

- Run the script 'deploy_infra.sh' to deploy.  
- There are some variables which you can change to modify the name of the managed domain, etc.

## Post deployment:
Configure the managed domain per your chosen architecture

#### Add a UPN suffix
If the managed domain is going to be used as the authoritive source for identities a UPN suffix must be added to the domain which matches the vanity domain configured in Azure Active Directory.  Use the Active Directory Domains and Trusts MMC add this UPN suffix to the domain.

![UPN](https://raw.githubusercontent.com/MSBrett/wvd_aio/master/resources/UPN.png)
#### Ports needed for AD Domain Join
If one wishes to secure traffic to the domain controller subnet (NSG or Azure Firewall) these are the ports required for the WVD clients to join the domain:
- TCP In: 53, 88, 135, 139, 389, 445, 636, 3268, 3269, 49152-65535
- UDP In: 53, 123, 137, 138, 389, 123, 49152-65536
- ICMP In: used for slow link detection when applying GPOs at logon

