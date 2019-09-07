#!/bin/sh

dyson manifest \
      --name=idp \
      --domain=idp.christine.website \
      --dockerImage=xena/idp:031320190918 \
      --containerPort=5000 \
      --replicas=1 \
      --useProdLE=true | kubectl apply -f-
