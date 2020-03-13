#!/bin/bash
eval $(ssh-agent -s) 
ssh-add <(echo "$ELM_UI_TESTING_SSH_PRIVATE_KEY") 

# List out your new key's fingerprint
ssh-add -l
ssh -T git@github.com
echo "Success?"