# Atomic will not resolve the issue

Example chart: https://github.com/distorhead/ex-helm-upgrade-failure

1. Check out master, run deploy.

```
git clone https://github.com/distorhead/ex-helm-upgrade-failure
cd ex-helm-upgrade-failure
helm upgrade --atomic --install --namespace myns myrelease .
```

Chart contains 2 deployments -- `myserver1` and `myserver2`:

```
Release "myrelease" does not exist. Installing it now.
NAME:   myrelease
LAST DEPLOYED: Tue Feb  5 23:48:57 2019
NAMESPACE: myns
STATUS: DEPLOYED

RESOURCES:
==> v1beta1/Deployment
NAME       READY  UP-TO-DATE  AVAILABLE  AGE
myserver1  1/1    1           1          5s
myserver2  1/1    1           1          5s
```

2. Make breaking change. Delete deployment `myserver1` from chart and modify deployment `myserver2` with user-error (delete image field for example):

```
git checkout break-atomic
git diff master
```

```
diff --git a/templates/deploy.yaml b/templates/deploy.yaml
index 198516e..64be153 100644
--- a/templates/deploy.yaml
+++ b/templates/deploy.yaml
@@ -1,21 +1,5 @@
 apiVersion: apps/v1beta1
 kind: Deployment
-metadata:
-  name: myserver1
-spec:
-  replicas: 1
-  template:
-    metadata:
-      labels:
-        service: myserver1
-    spec:
-      containers:
-      - name: main
-        command: ["/bin/bash", "-c", "while true ; do date ; sleep 1 ; done"]
-        image: ubuntu:16.04
----
-apiVersion: apps/v1beta1
-kind: Deployment
 metadata:
   name: myserver2
 spec:
@@ -28,4 +12,3 @@ spec:
       containers:
       - name: main
         command: ["/bin/bash", "-c", "while true ; do date ; sleep 1 ; done"]
-        image: ubuntu:16.04
```

3. Run deploy:

```
git checkout break-atomic
helm upgrade --atomic --install --namespace myns myrelease .
```

Say hello to our friend again:

```
UPGRADE FAILED
ROLLING BACK
Error: Deployment.apps "myserver2" is invalid: spec.template.spec.containers[0].image: Required value
Error: no Deployment with the name "myserver1" found
```
