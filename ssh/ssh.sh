#!/usr/bin/env bash

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
cd ~/public_html/code/ssh/

cat config > ~/.ssh/config
find config.d/*.conf -type f -exec cat {} >> ~/.ssh/config \; -exec printf "\n\n" >> ~/.ssh/config \;

cat ductn > ~/.ssh/ductn

cat tci > ~/.ssh/tci

cat id_rsa > ~/.ssh/id_rsa

cat gss > ~/.ssh/gss
