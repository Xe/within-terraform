#!/bin/sh

dyson manifest \
      --name=tulpaforcexyz \
      --domain=tulpaforce.xyz \
      --dockerImage=xena/tulpaforce:20190906 \
      --containerPort=80 \
      --replicas=1 \
      --useProdLE=true | kubectl apply -f-
