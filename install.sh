#!/bin/bash
# installation of openssh server, config files and more

host_name="$(hostname)"
keyfile="id_rsa_$host_name"
user_name="$USER"
member_path="$HOME/.ssh/domain_members"
domain="stagecraft"


make_backups() {   
   if [ -f /etc/ssh/ssh_config ]; then
      sudo cp /etc/ssh/ssh_config /etc/ssh/ssh_config.old
   fi
   if [ -f /etc/ssh/sshd_config ]; then
      sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
   fi

   if [ -f $HOME/.ssh/config ]; then
      cp $HOME/.ssh/config $HOME/.ssh/config.old
   fi
   if [ -f $HOME/.ssh/authorized_keys ]; then
      cp $HOME/.ssh/authorized_keys $HOME/.ssh/authorized_keys.old
   fi
}

mainuser=$USER
copy_over(){
   sudo cp $HOME/git/etc/openssh-server/ssh_config /etc/ssh/ssh_config
   sudo cp $HOME/git/etc/openssh-server/sshd_config /etc/ssh/sshd_config
   mkdir -p $HOME/.ssh/domain_members
   cp -r $HOME/git/etc/openssh-server/domain_members $HOME/.ssh/
}

install_ssh() {
   cd $HOME/git/etc
   git pull
   sudo apt update
   sudo apt install openssh-server
}
create_id() {
   #Create public/private key pair
   echo "Hint: Press ONLY <enter> when prompted for password!"
   echo "$HOME/.ssh/${keyfile}" | ssh-keygen -t rsa -b 4096
   cp "$HOME/.ssh/${keyfile}.pub" "$member_path/${keyfile}.pub"
   #Create domain_member config file
   if [ -f ${member_path}/${host_name}.config ]; then
      rm -f ${member_path}/${host_name}.config
   fi
   touch ${member_path}/${host_name}.config
   echo "Host ${host_name}" >> ${member_path}/${host_name}.config
   echo "   Hostname ${host_name}.${domain}" >> ${member_path}/${host_name}.config
   echo "   User ${user_name}" >> ${member_path}/${host_name}.config
   #Create global config file
   if [ -f $HOME/.ssh/config ]; then
      rm -f $HOME/.ssh/config
   fi
   cd $member_path
   for i in *.config; do
   cat "$i" >> $HOME/.ssh/config
   echo "" >> $HOME/.ssh/config
   done
   cat $HOME/git/etc/openssh-server/config >> $HOME/.ssh/config
   echo "   IdentityFile $HOME/.ssh/${keyfile}" >> $HOME/.ssh/config
   
   #Create authorized keys file
   cd $HOME/.ssh
   if [ -f authorized_keys ]; then
      rm -f authorized_keys
   fi
   cd $member_path
   for i in *.pub; do
      cat "$i" >> $HOME/.ssh/authorized_keys
   done
   chmod 600 $HOME/.ssh/authorized_keys
   #Update git files
   cd $HOME/git/etc
   cp $member_path/$host_name.config $HOME/git/etc/openssh-server/domain_members/$host_name.config
   cp $member_path/$keyfile.pub $HOME/git/etc/openssh-server/domain_members/$keyfile.pub
   echo "Updating git repository with new host information..."
   git add *
   git commit -m "Auto-update"
   git push origin master
   
}

start_service() {
   sudo ufw allow openssh
   sudo ufw enable
   sudo ufw status verbose
   sudo systemctl start sshd
}
### SCRIPT STARTS HERE
echo "Installing from this script will DELETE any inital SSH settings."
   read -p "Press Y to continue: " response
   
   case $response in
      y|Y)
         echo "Proceding with installation..."
         install_ssh
         make_backups
         copy_over
         create_id
         start_service
         ;;
      *)
         echo "Exiting..."
         exit
         ;;
   esac



