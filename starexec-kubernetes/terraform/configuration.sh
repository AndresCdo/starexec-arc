#!/bin/bash

# For configuration of the cluster (domain name, etc)
domain=starexec.mckeown.in
desiredNodes=3
maxNodes=5
instanceType="t3.small" # https://aws.amazon.com/ec2/instance-types/
# StarExec Cloud proposal suggested x2iedn.xlarge


if ! [ -z ${1+x} ]; then echo ${!1}; fi