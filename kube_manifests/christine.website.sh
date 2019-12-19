#!/bin/sh

latest_commit=$(git ls-remote git://github.com/Xe/site \
	   | grep refs/heads/master \
	   | cut -f 1 \
	   | head -c7)

echo "deploying xena/christinewebsite:$latest_commit"

kubens apps
dyson manifest \
      --name=christinewebsite \
      --domain=christine.website \
      --dockerImage=xena/christinewebsite:$latest_commit \
      --containerPort=5000 \
      --replicas=1 \
      --useProdLE=true | kubectl apply -f-
