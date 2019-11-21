#!/bin/sh

dyson manifest \
      --name=olin \
      --domain=olin.within.website \
      --dockerImage=xena/olin \
      --containerPort=5000 \
      --replicas=1 \
      --useProdLE=true | kubectl apply -f-
