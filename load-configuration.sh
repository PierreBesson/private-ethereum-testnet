#!/bin/bash

CONFIG_DIRECTORY=${1:-"configuration"}
echo "using configuration: from '${CONFIG_DIRECTORY}'"

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: network-configs
spec:
    accessModes:
    - ReadWriteOnce
    resources:
        requests:
            storage: 1Gi
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: temp-network-configs-pod
spec:
  containers:
  - name: temp-container
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - mountPath: /network-configs
      name: my-volume
  securityContext:
    fsGroup: 10001 # to be same group as the lighthouse container
  volumes:
    - name: my-volume
      persistentVolumeClaim:
        claimName: network-configs
  restartPolicy: Never
EOF
sleep 10
kubectl cp $CONFIG_DIRECTORY/network-configs temp-network-configs-pod:/

# check
kubectl exec -it temp-network-configs-pod -- chmod -R 777 network-configs # need to figure out permission later
kubectl exec -it temp-network-configs-pod -- ls -larth /network-configs

# clean
kubectl delete pod temp-network-configs-pod

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: validator-keys
spec:
    accessModes:
    - ReadWriteOnce
    resources:
        requests:
            storage: 1Gi
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: temp-validator-keys-pod
spec:
  containers:
  - name: temp-container
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - mountPath: /validator-keys
      name: my-volume
  securityContext:
    fsGroup: 10001 # to be same group as the lighthouse container
  volumes:
    - name: my-volume
      persistentVolumeClaim:
        claimName: validator-keys
  restartPolicy: Never
EOF

sleep 10
kubectl cp $CONFIG_DIRECTORY/validator-keys temp-validator-keys-pod:/

# check
kubectl exec -it temp-validator-keys-pod -- chmod -R 777  validator-keys # need to figure out permission later
kubectl exec -it temp-validator-keys-pod -- ls -larth /validator-keys

# clean
kubectl delete pod temp-validator-keys-pod