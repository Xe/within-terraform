#!/bin/sh

dyson manifest \
      -n=withinwebsite \
      -d=within.website \
      --dockerImage=xena/within.website:060920191632 \
      -c=5000 \
      -r=1 \
      -u=true | kubectl apply -f-
