#!/bin/sh

dyson manifest \
      --name=withinwebsite \
      --domain=within.website \
      --dockerImage=xena/within.website:060920191632 \
      --containerPort=5000 \
      --replicas=1 \
      --useProdLE=true | kubectl apply -f-
