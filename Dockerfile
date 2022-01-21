FROM debian

# import CTF-Guess-ThePassword
ADD ./CTF-Guess-The-Password /CTF
WORKDIR /CTF

# update and install needed stuff
RUN apt update -y && apt upgrade -y && apt install vsftpd -y && apt install git -y && apt install systemctl -y
RUN apt install python3-full -y && apt install python3-pip -y
#RUN python3 -m pip install-U pip && python3 -m pip install hashlib

# setup ftp vuln
RUN systemctl enable vsftpd && systemctl start vsftpd

# change root passowrd
#RUN echo -e "root\nroot" | passwd

# start the server
CMD python3 ./server.py

# Expose necessary ports
EXPOSE 20/tcp
EXPOSE 21/tcp
EXPOSE 9009/tcp
