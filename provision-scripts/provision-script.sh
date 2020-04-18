#!/bin/bash

AZ_USER_NAME=${1}
AZ_USER_PASSWORD=${2}
AZ_TENANT_ID=${3}
AZ_SUBSCRIPTION_ID=${4}
SP_NAME=${5}
SP_SECRET=${6}
SP_OBJECT_ID=${7}
SP_APP_ID=${8}

echo "`date` --BEGIN-- Provision Stage 1 Script" >>/root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting Time Zone" >>/root/provision-script-output.log
	echo "`date`" >>/root/provision-script-output.log
	timedatectl set-timezone America/Detroit >>/root/provision-script-output.log
	echo "`date`" >>/root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Setting Student User password to 'Microsoft'" >>/root/provision-script-output.log
	echo "Microsoft" | passwd --stdin student
echo "********************************************************************************************"
	echo "`date` -- Adding student to wheel group for sudo access'" >>/root/provision-script-output.log
	usermod -G wheel student
echo "********************************************************************************************"
	echo "`date` -- Setting Root Password to 'Microsoft'" >>/root/provision-script-output.log
	echo "Microsoft" | passwd --stdin root
echo "********************************************************************************************"
	echo "`date` -- Adding 'deltarpm' and other required RPMs" >>/root/provision-script-output.log
        sed -i "s/=enforcing/=disabled/g" /etc/selinux/config
        setenforce 0
        echo "plugins=0" >> /etc/dnf/dnf.conf
	yum -y install drpm >> /root/yum-output.log
        yum -y install python2-devel python2-pip libxslt-devel libffi-devel openssl-devel iptables arptables ebtables iptables-services telnet nodejs npm >> /root/yum-output.log
        yum -y install @python27 >> /root/yum-output.log
        yum -y install @development >> /root/yum-output.log
        yum -y group install "Server with GUI" --skip-broken >> /root/yum-output.log
        echo "student ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        alternatives --set python /usr/bin/python2
        cd /usr/bin
        curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
        chmod 755 /usr/bin/kubectl
echo "********************************************************************************************"
	echo "`date` -- Securing host and changing default SSH port to 2112" >>/root/provision-script-output.log
	sed -i "s/dport 22/dport 2112/g" /etc/sysconfig/iptables
	semanage port -a -t ssh_port_t -p tcp 2112
	sed -i "s/#Port 22/Port 2112/g" /etc/ssh/sshd_config
	systemctl restart sshd
	systemctl stop firewalld
	systemctl disable firewalld
	systemctl mask firewalld
	systemctl enable iptables
	systemctl start iptables	
echo "********************************************************************************************"
        echo "`date` -- Upgrading PIP and installing Ansible" >>/root/provision-script-output.log
        runuser -l student -c "pip-2.7 install --upgrade --user python-dateutil"
        runuser -l student -c "pip-2.7 install --upgrade --user openshift"
        runuser -l student -c "pip-2.7 install --upgrade --user requests"
        runuser -l student -c "pip-2.7 install --upgrade --user xmltodict"
        runuser -l student -c "pip-2.7 install --upgrade --user pyOpenSSL"
        runuser -l student -c "pip-2.7 install --upgrade --user podman"
        runuser -l student -c "pip-2.7 install --user ansible==2.9.6"
        yum -y remove rhn-check rhn-client-tools rhn-setup rhnlib rhnsd yum-rhn-plugin PackageKit* subscription-manager >>/root/yum-output.log
        echo "[defaults]" > /home/student/.ansible.cfg
        echo "no_log = True" >> /home/student/.ansible.cfg
        echo "[ssh_connection]" >> /home/student/.ansible.cfg
        echo "ssh_args = -o StrictHostKeyChecking=no" >> /home/student/.ansible.cfg
        chown student:student /home/student/.ansible.cfg
echo "********************************************************************************************"	
	echo "`date` -- Installing the Azure Linux CLI" >>/root/provision-script-output.log
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
	yum -y install azure-cli >> /root/yum-output.log
echo "********************************************************************************************"	
	echo "`date` -- Setting default systemd target to graphical.target" >>/root/provision-script-output.log
	systemctl set-default graphical.target >> /root/provision-script-output.log
echo "********************************************************************************************"
	echo "`date` -- Installing noVNC environment" >>/root/provision-script-output.log
	yum -y install tigervnc-server tigervnc >> /root/yum-output.log
        pip-2.7 install numpy websockify
        chmod -R a+rx /usr/lib64/python2.7/site-packages/numpy*
        chmod -R a+rx /usr/lib/python2.7/site-packages/websockify*
        wget --quiet -P /usr/local https://github.com/novnc/noVNC/archive/v1.1.0.tar.gz
        cd /usr/local
        tar xvfz v1.1.0.tar.gz
        ln -s /usr/local/noVNC-1.1.0/vnc.html /usr/local/noVNC-1.1.0/index.html
        wget --quiet -P /etc/systemd/system https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2020/master/provision-scripts/websockify.service
	wget --quiet --no-check-certificate -P /etc/systemd/system "https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2020/master/provision-scripts/vncserver@:4.service"
	openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/pki/tls/certs/novnc.pem -out /etc/pki/tls/certs/novnc.pem -days 365 -subj "/C=US/ST=Michigan/L=Ann Arbor/O=RedHatSummit/OU=CloudNativeAzure/CN=microsoft.com"
	su -c "mkdir .vnc" - student
	wget --quiet --no-check-certificate -P /home/student/.vnc https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2020/master/provision-scripts/passwd
	wget --quiet --no-check-certificate -P /home/student/.vnc https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2020/master/provision-scripts/xstartup
        chown student:student /home/student/.vnc/passwd
        chown student:student /home/student/.vnc/xstartup
        chmod 600 /home/student/.vnc/passwd
        chmod 755 /home/student/.vnc/xstartup
	iptables -I INPUT 1 -m tcp -p tcp --dport 6080 -j ACCEPT
	service iptables save
        chmod 644 /etc/systemd/system/pm2-root.service
        chmod 644 /etc/systemd/system/vncserver@\:4.service
        chmod 644 /etc/systemd/system/websockify.service
        systemctl daemon-reload
        systemctl enable vncserver@:4.service
        systemctl enable websockify.service
        systemctl start vncserver@:4.service
	systemctl start websockify.service
echo "********************************************************************************************"
	echo "`date` -- Editing student's .bashrc and disabling Red Hat alerts" >> /root/provision-script-output.log
	echo " " >> /home/student/.bashrc
        echo "# Azure Service Principal Credentials" >> /home/student/.bashrc
	echo "export AZURE_CLIENT_ID=$SP_APP_ID" >> /home/student/.bashrc
	echo "export AZURE_SECRET=$SP_SECRET" >> /home/student/.bashrc
	echo "export AZURE_SUBSCRIPTION_ID=$AZ_SUBSCRIPTION_ID" >> /home/student/.bashrc
	echo "export AZURE_TENANT=$AZ_TENANT_ID" >> /home/student/.bashrc
        su -c "gconftool-2 -t bool -s /apps/rhsm-icon/hide_icon true" - student
	su -c "ssh-keygen -t rsa -q -P '' -f /home/student/.ssh/id_rsa" - student
        mkdir -p /home/student/.local/share/keyrings
	wget --quiet -P /home/student/.local/share/keyrings https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2020/master/provision-scripts/Default.keyring
        chown student:student /home/student/.local/share/keyrings/Default.keyring
        restorecon /home/student/.local/share/keyrings/Default.keyring
echo "********************************************************************************************"
        wget -P /etc/yum.repos.d https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2020/master/provision-scripts/mongodb-org-4.2.repo 
        yum -y update kernel
        yum -y install mongodb-org 
        npm install pm2@latest -g
        systemctl enable mongod
        systemctl start mongod
        iptables -I INPUT 2 -m tcp -p tcp --dport 80 -j ACCEPT
        export MONGO_DBCONNECTION="mongodb://localhost:27017/nodejs-todo"
        mkdir -p /source/sample-apps/nodejs-todo/src
        cd /source/sample-apps/nodejs-todo/src   
        git clone https://github.com/stuartatmicrosoft/nodejs-todo .
        chown -R student:student /source
        npm install
        sed -i "s/8080/80/g" /source/sample-apps/nodejs-todo/src/server.js
        pm2 start server.js
        pm2 save
        pm2 startup systemd -u root
        systemctl start pm2-root
        service iptables save
echo "********************************************************************************************"
        chown -R student:student /home/student/.local
        chmod a+rx /home/student/.local
        yum -y update
        cd /usr/local/bin
        wget -P /usr/local/bin https://raw.githubusercontent.com/stuartatmicrosoft/RedHatSummit2020/master/provision-scripts/oc.tar.gz
        tar xvfz oc.tar.gz
        rm -f oc.tar.gz
echo "********************************************************************************************"
        echo "`date` -- Installing MSSQL Tools" >>/root/provision-script-output.log
        curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/msprod.repo
        runuser -l student -c "echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile"
        runuser -l student -c "echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc"
        ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel
echo "********************************************************************************************"

echo "`date` --END-- Provisioning" >>/root/provision-script-output.log

echo "`date` Creating Student Desktop Credentials File" >>/root/provision-script-output.log

echo AZURE_USER_NAME=$AZ_USER_NAME >> /home/student/Desktop/credentials.txt
echo AZURE_USER_PASSWORD=$AZ_USER_PASSWORD >> /home/student/Desktop/credentials.txt
echo AZURE_CLIENT_ID=$SP_APP_ID >> /home/student/Desktop/credentials.txt
echo AZURE_SECRET=$SP_SECRET >> /home/student/Desktop/credentials.txt
echo AZURE_SUBSCRIPTION_ID=$AZ_SUBSCRIPTION_ID >> /home/student/Desktop/credentials.txt
echo AZURE_TENANT_ID=$AZ_TENANT_ID >> /home/student/Desktop/credentials.txt
echo GUIDE_URL=https://github.com/stuartatmicrosoft/RedHatSummit2020 >> /home/student/Desktop/credentials.txt
chown student:student /home/student/Desktop/credentials.txt

echo "`date` --END-- Provision Script" >>/root/provision-script-output.log

