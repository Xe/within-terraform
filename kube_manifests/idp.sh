#!/bin/sh

dyson manifest \
      --name=idp \
      --domain=idp.christine.website \
      --dockerImage=docker.pkg.github.com/xe/x/h:v1.1.8 \
      --containerPort=5000 \
      --replicas=1 \
      --useProdLE=true | kubectl apply -f-
