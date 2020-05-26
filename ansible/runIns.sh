#!/bin/bash

. ./openrc.sh; ansible-playbook -i hosts --ask-become-pass -vvv all-in-one.yaml

