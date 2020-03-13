#!/bin/bash
eval "$(ssh-agent -s)"
ssh-add - <<< "${ELM_UI_TESTING_SSH_PRIVATE_KEY}"
ssh -T git@github.com