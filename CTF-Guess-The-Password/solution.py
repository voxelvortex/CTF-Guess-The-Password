from encoding import Encoder


def main():
    encoder = Encoder("supersecret.json")

    # We know the password is 6 digits, so lets generate all possible combinations
    possible_answers = set()
    for i in range(1000000):
        possible_answer = str(i)

        while(len(possible_answer) < 6):
            possible_answer = "0" + possible_answer
        possible_answers.add(possible_answer)

    print("Generated possible passwords...\nStarting checks...")

    # now possible_answers is a set that has "000000", "000001", ..., "999999"
    # we can now try brute forcing the flag

    for possible_answer in possible_answers:
        if encoder.check_input(possible_answer):
            print(f"The password is probably: {possible_answer}")
            flag = encoder.flag_from_pwd(possible_answer)
            print(f"That means the flag is <RITSEC{ {flag} }>")

    print("Done with checks!")

    # The user could also feed the secret to the server, and it should spit out the flag




if __name__ == "__main__":
    main()