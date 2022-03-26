# CTF-Guess-The-Password
A quick ctf challenge for RITSEC I wrote
This challenge aims at pushing you to use ncat for probing. You should be able to find the vulnerability using only ncat if you choose to pursue that challenge, exploiting will require some python reverse engineering

------

# How to deploy

To deploy the challenge:
1. First we copy the files to ./Deploy

    I've made a bash script to do this automatically, you can use it by running:

    `sh make_deploy.sh`

2. Now we can use docker-compose to spin up the containers by running:

    `docker-compose up -d`

3. When you're done running the ctf you can stop the containers by running:

    `docker-compose down`

    You might also consider getting rid of your dangling images to save space with:

    `docker image prune`

------

## CTF Challenge info:

### Name: 
Password Guess?

### Description: 
We found a VIP's box, but when we try to guess his short password, we get rate limited! Can you find a way around the rate limiting to get the password?

<ip and main service port information>

### Hint:
Is there anything open other than the main service?
