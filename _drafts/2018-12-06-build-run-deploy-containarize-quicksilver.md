---
layout: post
title:  "Build, run and deploy containerize Quicksilver"
date:   2018-06-12 12:00:00
tags: [docker, episerver]
comments: true
---

## Build Quicksilver in a container

## Run Quicksilver using docker compose

## Deploy to Azure Container Services (ACS)
This [tutorial](https://code.visualstudio.com/tutorials/docker-extension/getting-started)

### Set up Azure environment for Azure Container Instances (ACI)
This [tutorial](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quickstart)

`az group create --name qs-resource-group --location westeurope`

`az container create --resource-group qs-resource-group --name mycontainer --image microsoft/aci-helloworld --dns-name-label aci-demo-brianweet --ports 80`

`az container show --resource-group qs-resource-group --name mycontainer --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --out table`
```
FQDN                                             ProvisioningState
-----------------------------------------------  -------------------
aci-demo-brianweet.westeurope.azurecontainer.io  Succeeded
```
<p class="centered-image">
	<img src="/assets/docker-aci/first-aci-container.png" alt="First try ACI, success">	
</p>

`az container logs --resource-group qs-resource-group --name mycontainer`

`az container attach --resource-group qs-resource-group -n mycontainer`

`az container delete --resource-group qs-resource-group --name mycontainer`

`az container list --resource-group qs-resource-group --output table`


Create container registry `qsregistry` to push our images to:
`az acr create --resource-group qs-resource-group --name qsregistry --sku Basic --admin-enabled true`

Log in to the registry
`az acr login --name qsregistry`

Push our images to the registry (tag and push)
`docker tag quicksilver-db:latest qsregistry.azurecr.io/quicksilver-db:v1`
`docker push qsregistry.azurecr.io/quicksilver-db:v1`

### create service principal to automate azure cli commands
* As I don't want to install the CLI I'll use the microsoft/azure-cli image.
  * `docker run --platform linux -it microsoft/azure-cli`
* Now from within the image, log in interactively (have to browse to the url):
  * `az login`
  * Result
    ```json
    To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code xx to authenticate.
        [
            {
                "cloudName": "AzureCloud",
                "id": "xxxx-xx-xx-xx-xxxx",
                "isDefault": true,
                "name": "Visual Studio with MSDN",
                "state": "Enabled",
                "tenantId": "xxxx-xx-xx-xx-xxxx",
                "user": {
                "name": "brian",
                "type": "user"
                }
            }
        ]
    ```
* 

qs-sf
qs-sf-user
y15Z1fJxxepgIGQ6rGnV