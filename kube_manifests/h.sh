#!/bin/sh

dyson manifest \
      -n=hlang \
      -d=h.christine.website \
      --dockerImage=docker.pkg.github.com/xe/x/h:v1.1.8 \
      -c=5000 \
      -r=1 \
      -u=true | kubectl apply -f-
