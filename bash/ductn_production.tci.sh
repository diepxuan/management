#!/bin/bash

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
ssh app.gem.tci "
mkdir -p ~/.ssh
chmod 700 ~/.ssh
"
# cat /var/www/base/ssh/gss.pub | ssh app.gem.tci "cat >> ~/.ssh/authorized_keys"

# ssh private key
cat /var/www/base/ssh/tci | ssh app.gem.tci "cat > ~/.ssh/id_rsa"
cat /var/www/base/ssh/tci.pub | ssh app.gem.tci "cat > ~/.ssh/id_rsa.pub"
ssh app.gem.tci "chmod 600 ~/.ssh/*"

# echo  "
# Host tci.staging
#     HostName 128.199.118.164
#     User gssadmin
# " | ssh app.gem.tci "cat >> ~/.ssh/config"
