#!/bin/bash

####################################
#
# completion
#
####################################
cat ~/public_html/code/bash/.bash_aliases | ssh gsmartsolutions.staging "cat > ~/.bash_aliases"
scp -r ~/public_html/code/bash/completion gsmartsolutions.staging:~/
ssh gsmartsolutions.staging "chmod 775 ~/completion"

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
ssh gsmartsolutions.staging "
mkdir -p ~/.ssh
chmod 700 ~/.ssh
"
# cat ~/public_html/code/ssh/tci.pub | ssh gsmartsolutions.staging "cat >> ~/.ssh/authorized_keys"

# ssh private key
cat ~/public_html/code/ssh/tci | ssh gsmartsolutions.staging "cat > ~/.ssh/id_rsa"
ssh gsmartsolutions.staging "chmod 600 ~/.ssh/*"
