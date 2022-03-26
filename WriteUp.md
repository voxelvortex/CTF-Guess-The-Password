# Write up for CTF-Guess-The-Password

## We're given:
```
Name: 
Password Guess?

Description: 
We found a VP's box, but when we try to brute force his short password, we get rate limited! Can you find a way around the rate limiting to get the password?

127.0.0.1 9009
```

## Getting started

So to start with lets ncat the given ip and port and see what's being hosted there.


```
[michael] ~ > ncat 127.0.0.1 9009 -v                                     
Ncat: Version 7.80 ( https://nmap.org/ncat )
Ncat: Connected to 127.0.0.1:9009.

Enter the passcode to access the secret: 
test
That password isn't right!
	Hint: Your password might be a date in the format YYMMDD

Closing connection...
```

So that lets us know that the password is some 6 digit integer, so we could try to brute force the password, but we quickly find out that the server has some pretty liberal rate limiting...

```
[michael] ~ > ncat 127.0.0.1 9009
Enter the passcode to access the secret: 
test
That password isn't right!
	Hint: Your password might be a date in the format YYMMDD

Closing connection...

[michael] ~ > ncat 127.0.0.1 9009
You are being rate limited
```

-----

## Taking a different approach

Okay so trying to brute force the password is going to take too long, and obviously isn't the intended solution, so let's try something else.

Let's see if there are any other ports are open, maybe there's something else we can try. We can do a quick port scan with nmap

```
[michael] ~ > nmap -sT 127.0.0.1
Starting Nmap 7.80 ( https://nmap.org ) at 2022-03-26 01:23 EDT
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00012s latency).
Not shown: 997 closed ports
PORT     STATE SERVICE
20/tcp   open  ftp-data
21/tcp   open  ftp
9009/tcp open  pichat
```

Okay, interesting! Looks like ftp is open. Let's see if we can poke around, maybe we can grab files from the server or something...

------
## Checking out FTP

We can try to connect to the FTP server, I like using Filezilla for FTP stuff so I'm going to use that.

<img src="./write-up/FTProot.png">

Upon trying to connect as root we get denied and told that the server is anonymous only... 

We can reconnect without a username and we get the following

<img src="./write-up/FTPanon.png">

Okay cool, we're in. Let's see what we have to work with!

<img src="./write-up/FTPdir.png">

With a name like "DONTLOOKHERE" it's obviously the first place we check!

<img src="./write-up/FTPsourcecode.png">

Okay it looks like we have some "source code" for something... Let's download it and take a quick look.

-----

## Analysing the source code

When we take a look at the "source code", it quickly becomes apparent that this is the source code for the server we were trying to get into earlier, lucky!

Skimming through server.py there's a snippet that jumps out at me:

```python
if len(user_input) == 6 and self.encoder.check_input(user_input):
    secret = self.encoder.flag_from_pwd(user_input)
    response = f"RITSEC{{secret}}\n"
```

It seems like there's some call to an "encoder" function that checks the input, and then if that input is right, it uses it to get a flag...

The definition of the encoder object is `self.encoder = Encoder("supersecret.json")`, so let's go check out supersecret.json and Encoder.py

```json
{
  "key":"122ecadd08f6a45620ee9d005252e8a9afaa4e19536eb5684d886b658874182c",
  "secret":"f`I]@|"
}
```

So the json file has a key and a secret; key is a hash and secret is a 6 character long string that is seemingly random.

Taking a quick peek at encoding.py, it looks like `check_input()` hashes `user_input` and checks if it's equal to the key. `flag_from_pwd()` takes a `key`, xor's it against `secret` and returns it. 

```python
def flag_from_pwd(self, key):
    byte_secret = self.secret.encode()
    byte_key = key.encode()
    return bytes(a ^ b for a, b in zip(byte_secret, byte_key)).decode()

def check_input(self, user_input):
    hashed_user_input = self.hash(user_input)
    return hashed_user_input == self.hashed_key
```
------

## The solution

There's no way to xor the flag without knowing the password. Luckily since we have the source code, we can get rid of that pesky rate limiting, and since the password is a 6 digit long integer brute forcing it should be easy.

Lets make a short python program...

```python
# import the Encoder code, all the rate limiting is part of the server so we can spam calls without any worries
from encoding import Encoder



def main():
    # Let's make an encoder object with the secret json file
    encoder = Encoder("supersecret.json")



    # We know the password is 6 digits, so lets generate all possible combinations
    possible_answers = set()

    # And then let's loop through them and see if they're right
    for i in range(1000000):
        possible_answer = str(i)

        # Make sure we're always guess that's 6 characters long
        while(len(possible_answer) < 6):
            possible_answer = "0" + possible_answer
        possible_answers.add(possible_answer)

    print("Generated possible passwords...\nStarting checks...")

    # now possible_answers is a set that has "000000", "000001", ..., "999999"
    # we can now try brute forcing the flag

    for possible_answer in possible_answers:
        if encoder.check_input(possible_answer):
            # if we get the hash to check out, we'll print what we found
            print(f"The password is probably: {possible_answer}")

            # And then we'll print out what that flag would be
            flag = encoder.flag_from_pwd(possible_answer)
            print(f"That means the flag is <RITSEC{ {flag} }>")

    print("Done with checks!")

    # You could also feed the possible_answer to the server, and it would spit out the flag



if __name__ == "__main__":
    main()
```

or without comments:

```python
from encoding import Encoder

def main():
    encoder = Encoder("supersecret.json")

    possible_answers = set()
    for i in range(1000000):
        possible_answer = str(i)

        while(len(possible_answer) < 6):
            possible_answer = "0" + possible_answer
        possible_answers.add(possible_answer)

    print("Generated possible passwords...\nStarting checks...")

    for possible_answer in possible_answers:
        if encoder.check_input(possible_answer):
            print(f"The password is probably: {possible_answer}")
            flag = encoder.flag_from_pwd(possible_answer)
            print(f"That means the flag is <RITSEC{ {flag} }>")

    print("Done with checks!")

if __name__ == "__main__":
    main()
```

When we run it we get:
```
[michael] CTF-Guess-The-Password > python3 solution.py                                                                      Generated possible passwords...
Starting checks...
The password is probably: 691228
That means the flag is RITSEC{'PYxorD'}
Done with checks!
```

We submit the flag and get some points!