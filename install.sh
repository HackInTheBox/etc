#!/bin/bash
# installation of openssh server, config files and more

sudo apt update
sudo apt install openssh-server
host_name=$(hostname)
keyfile="$HOME/.ssh/id_rsa_$host_name"
echo "$keyfile" | ssh-keygen -t rsa -b 4096
cat "${keyfile}.pub" >> $HOME/.ssh/authorized_keys
chmod 600 $HOME/.ssh/authorized_keys

make_backups() {
   if [ -f /etc/ssh/ssh_config ]; then
      cp /etc/ssh/ssh_config /etc/ssh/ssh_config.old
   fi
   if [ -f /etc/ssh/sshd_config ]; then
      cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
   fi
   if [ -f $HOME/.ssh/config ]; then
      cp $HOME/.ssh/config $HOME/.ssh/config.old
   fi
   if [ -f $HOME/.ssh/authorized_keys ]; then
      cp $HOME/.ssh/authorized_keys $HOME/.ssh/authorized_keys.old
   fi
   if [ -d $HOME/.ssh/public_keys ]; then
      mv $HOME/.ssh/public_keys $HOME/.ssh/public_keys.old
   fi  
}
make_backups
copy_over(){
   sudo cp $HOME/git/etc/etc/ssh/ssh_config /etc/ssh/ssh_config
   sudo cp $HOME/git/etc/etc/ssh/sshd_config /etc/ssh/sshd_config
   cp $HOME/git/etc/home/user/.ssh/config $HOME/.ssh/config
   cp $HOME/git/etc/home/user/.ssh/authorized_keys $HOME/.ssh/authorized_keys
   cp -r $HOME/git/etc/home/user/.ssh/public_keys $HOME/.ssh/public_keys
   
}

copy_over

sudo ufw allow openssh-server
sudo systemctl start sshd
