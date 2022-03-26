#! /bin/bash

mkdir -p ./Deploy

for file in "encoding.py" "server.py" "supersecret.json"
do
    cp -v ./CTF-Guess-The-Password/$file ./Deploy/$file
done