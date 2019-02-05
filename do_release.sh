#!/bin/bash

export HELM_HOST=localhost:44134
$GOPATH/src/k8s.io/helm/bin/helm upgrade --atomic --timeout 30 --install --namespace myns myrelease .
