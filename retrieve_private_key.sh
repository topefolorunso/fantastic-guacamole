#!/bin/bash

# set the variable to store name of the key pair
keyPairName=""

# promts user to provide a valid key pair name if it hasn't been modified in the file or while the user enters an empty string as input
while [ -z $keyPairName ];

    do

        echo "invalid key pair name!"
        echo "you need to provide a non-empty string as the key pair name!"
        echo "kindly enter a valid name for the key pair:"
        echo ""

        read keyPairName

    done  

# fetch the ID of the key pair and set the variable to store it
keyPairID=$(aws ec2 describe-key-pairs \
    --filters Name=key-name,Values=$keyPairName \
    --query KeyPairs[*].KeyPairId \
    --output text)

# echo "keyPairID = $keyPairID"

if [ -z $keyPairID ]

    then

        # stop running the script if the key pair does not exist
        echo "the key pair with the name [$keyPairName] does not exist in aws systems manager parameter store."
        echo "please create a valid key pair with cloudformation or check the key pair name and try again!"

    else # continue running the script if the key pair exists

        # you should (or rather, can) modify the file name (if you wish)
        fileName="private_key"

        # fetch the private key and store it in the .pem file
        aws ssm get-parameter \
            --name /ec2/keypair/$keyPairID \
            --with-decryption \
            --query Parameter.Value \
            --output text > $fileName.pem

        # protect the key file from read/write operations
        chmod 400 $fileName.pem

fi
