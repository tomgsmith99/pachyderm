#!/bin/bash

# Check the cron value to see if this is a daily job

if [ "cron" == "cron" ]; then
	echo "Running daily benchmarks"
    # Use the secrets in the travis environment to setup the aws creds for the aws command:
    echo "${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}

" | aws configure
    make install
    echo "pachctl is installed here:"
    which pachctl
    # Travis doesn't come w an ssh key
    # kops needs one in place (because it enables ssh access to nodes w it)
    # for now we'll just generate one on the fly
    # travis supports adding a persistent one if we pay: https://docs.travis-ci.com/user/private-dependencies/#Generating-a-new-key
    ssh-keygen -t rsa -b 4096 -C "buildbot@pachyderm.io" -f $HOME/.ssh/id_rsa -N ''
    echo "generated ssh keys:"
    ls ~/.ssh
    cat ~/.ssh/id_rsa.pub

    # Need to login so that travis can push the bench image
    docker login -u pachydermbuildbot -p $DOCKER_PWD

    # Deploy cluster and run benchmark
	sudo -E make bench
else
	echo "Running tests"
	make test
fi
