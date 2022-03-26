FROM debian

# import CTF-Guess-ThePassword
ADD ./CTF-Guess-The-Password /CTF
WORKDIR /CTF

# update and install needed stuff
RUN apt-get update -y &&\
    #apt-get upgrade -y &&\ # You can comment this out for a faster build if you need to
    apt-get install -y vsftpd git systemctl python3-full python3-pip python3-wheel
# RUN python3 -m pip install -U pip hashlib

# setup ftp vuln
RUN systemctl enable vsftpd && systemctl start vsftpd

# change root passowrd
#RUN echo -e "root\nroot" | passwd

# start the server
CMD python3 ./server.py

# Expose necessary ports
#EXPOSE 20/tcp
#EXPOSE 21/tcp
#EXPOSE 9009/tcp
