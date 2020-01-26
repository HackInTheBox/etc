to install ssh:
# sudo apt install openssh-server

copy ssh_config and sshd_config to your /etc/ssh folder
copy config to /home/$USER/.ssh 

create a 4096 bit rsa key pair
save to /home/$USER/.ssh/$keyname (ie: /home/shawn/.ssh/id_rsa_laptop)
$ ssh-keygen -t rsa -b 4096

copy the public key to your authorized users list
$ cat /home/$USER/.ssh/${keyname}.pub >> /home/$USER/.ssh/authorized_keys

ensure permissions are correct
$ chmod 600 /home/$USER/.ssh/authorized_keys

edit your /home/$USER/.ssh/config file 
$ nano /home/$USER/.ssh/config

to start daemon listening for connections (default port 22)
# sudo systemctl start sshd

add firewall rule to allow incoming connections
# sudo ufw allow openssh

test to see if you can ssh into yourself
$ ssh -v localhost

Keep your private key on the computer it was generated and do not email it or copy it to another device.  Copy a public key into your authorized_keys file if you want the device with the associated private key to access you.  Each device on the network will generally have ONE private key, and a list of many public keys.  

Common problems are not having the correct permissions set in all of your ssh files and folders.  By default, ssh will not launch in an "unsecure" mode.  You can override this by setting "StrictModes" to "no" in /etc/ssh/sshd_config.


