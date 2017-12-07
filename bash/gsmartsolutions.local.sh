#!/bin/bash

####################################
#
# completion
#
####################################
cat ~/public_html/code/bash/.bash_aliases | ssh gsmartsolutions.local "cat > ~/.bash_aliases"
scp -r ~/public_html/code/bash/completion gsmartsolutions.local:~/.completion
ssh gsmartsolutions.local "chmod 775 ~/.completion"

####################################
#
# git
#
####################################
cat ~/public_html/code/bash/git/.gitignore | ssh gsmartsolutions.local "cat > ~/.gitignore"
ssh gsmartsolutions.local "
git config --global core.excludesfile ~/.gitignore

# setting
git config --global user.name \"Trần Ngọc Đức\"
git config --global user.email \"caothu91@gmail.com\"

# push
git config --global push.default simple

# file mode
git config --global core.fileMode false

# line endings
git config --global core.autocrlf false
git config --global core.eol lf

# Cleanup
git config --global gc.auto 0
"

####################################
#
# SSH
#
####################################
# Create PEM file
# ##############################
#
# openssl rsa -in id_rsa -outform PEM -out id_rsa.pem

# Change passphrase
# ##############################
# SYNOPSIS
# #ssh-keygen [-q] [-b bits] -t type [-N new_passphrase] [-C comment] [-f output_keyfile]
# #ssh-keygen -p [-P old_passphrase] [-N new_passphrase] [-f keyfile]
# #-f filename Specifies the filename of the key file.
# -N new_passphrase     Provides the new passphrase.
# -P passphrase         Provides the (old) passphrase.
# -p                    Requests changing the passphrase of a private key file instead of
#                       creating a new private key.  The program will prompt for the file
#                       containing the private key, for the old passphrase, and twice for
#                       the new passphrase.
#
# ssh-keygen -f id_rsa -p

# Setup
# ##############################
ssh gsmartsolutions.local "
mkdir -p ~/.ssh
chmod 700 ~/.ssh
"
# cat ~/public_html/code/ssh/gss.pub | ssh gsmartsolutions.local "cat >> ~/.ssh/authorized_keys"

# ssh private key
cat ~/public_html/code/ssh/gss | ssh gsmartsolutions.local "cat > ~/.ssh/id_rsa"
ssh gsmartsolutions.local "chmod 600 ~/.ssh/*"
