# Private Ethereum Network Deployent

## Documentation

The setup is fully documented in this article: [pierre-besson.fr/articles/2024/09/07/private-ethereum-testnet.html](https://pierre-besson.fr/articles/2024/09/07/private-ethereum-testnet.html)

## Quickstart

### Load network configuration

Switch your kubectl to the target Kubernetes cluster and namespace, and execute: 

```
./load-configuration.sh configuration-example
```

Wait for its completion. This should create, pre-populated `network-configs` and `validator-keys` volumes.

### Deploy the testnet

```
kustomize build --enable-helm | k apply -f -
```

This should deploy 3 nodes and start producing blocks:
* reth-bootnode-0
* lightouse-beacon-0
* lightouse-validator-0

### Deploy monitoring

Adapt the prometheus and loki endpoint configuration in `configuration-example/kustomization.yaml` to point to your instances and load it on your cluster with:

```
kustomize build --enable-helm configuration-example/ | k apply -f -
```

Deploy the Alloy agent:

```
kustomize build --enable-helm monitoring/ | k apply -f -
```