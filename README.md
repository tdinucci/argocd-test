# argocd-test

Make sure you have [Kind](https://kind.sigs.k8s.io) installed.

## Run
To get up and running execute:
```
./run.sh
```

This will:
* Create a deployment cluster (context is `kind-deployments`)
* Create a cluster which services are deployed into (context is `kind-services`)
* Install Argo CD and hook the clusters together
* Deploy a test `Application` to the Argo CD cluster

Once `run.sh` has done it's thing it'll print a URL for the Argo CD UI along with a username and password.  After you've logged in you should see one application called `guestbook` (this is just a stock Argo CD test service).  If you refresh and synchronise this it should be deployed to the `kind-services` cluster.

You can use `kubectl` as normal, just append a `--context ${CONTEXT}` flag, e.g:
```
kubectl --context kind-services -n io-gmon get pods
```

## Delete

To clean everything up run:
```
./delete.sh
```
