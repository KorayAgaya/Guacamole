#!/bin/sh
#############################################################
# This script was created by Hernan Dario Nacimiento based on:
#  http://guac-dev.org/release/release-notes-0-9-8
#  http://guac-dev.org/doc/0.9.8/gug/jdbc-auth.html
#  http://guac-dev.org/doc/0.9.8/gug/administration.html
# Task of this script:
# Install Packages Dependencies
# Download Guacamole and MySQL Connector packages
# Install Guacamole Server
# Install Guacamole Client
# Install MySQL Connector
# Configure MariaDB
# Configure FirewallD
# Setting Tomcat Server
#############################################################
#####    VARIABLES    ####
##########################
CENTOS_VER=`rpm -qi --whatprovides /etc/redhat-release | awk '/Version/ {print $3}'`
GUACA_VER="0.9.8"
MYSQL_CONNECTOR_VER="5.1.36"
SERVER_HOSTNAME="localhost"
INSTALL_DIR="/usr/local/src/guacamole/${GUACA_VER}/"
LIB_DIR="/var/lib/guacamole/"
PWD=`pwd`
logfile="${PWD}/guacamole-${GUACA_VER}."$(date +"%d-%y-%b")".log"
MYSQ_CONNECTOR_URL="http://dev.mysql.com/get/Downloads/Connector-J/"
MYSQL_CONNECTOR="mysql-connector-java-${MYSQL_CONNECTOR_VER}"
MYSQL_PORT="3306"
GUACA_PORT="4822"
GUACA_CONF="guacamole.properties"
GUACA_URL="http://sourceforge.net/projects/guacamole/files/current/"
GUACA_SERVER="guacamole-server-${GUACA_VER}" #Source
#GUACA_CLIENT="guacamole-client-${GUACA_VER}" #Source
GUACA_CLIENT="guacamole-${GUACA_VER}" #Binary
GUACA_JDBC="guacamole-auth-jdbc-${GUACA_VER}" #Extension
Black=`tput setaf 0`   #${Black}
Red=`tput setaf 1`     #${Red}
Green=`tput setaf 2`   #${Green}
Yellow=`tput setaf 3`  #${Yellow}
Blue=`tput setaf 4`    #${Blue}
Magenta=`tput setaf 5` #${Magenta}
Cyan=`tput setaf 6`    #${Cyan}
White=`tput setaf 7`   #${White}
Bold=`tput bold`       #${Bold}
Reset=`tput sgr0`      #${Reset}
#echo -e "${Red}red \n${Green}gree \n${Yellow}yellow \n${Blue}blue \n${Magenta}magenta \n${Cyan}cyan \n${White}white \n${Reset}"
##########################
#####      MENU      #####
##########################
clear
echo -e "
                                                                 
                                                                 
                                                ${Yellow}'.'              
                            ${Green}'.:///:-.....'     ${Yellow}-yyys/-           
                     ${Green}.://///++++++++++++++/-  ${Yellow}.yhhhhhys/'        
                  ${Green}'.:++++++++++++++++++++++: ${Yellow}'yhhhhhhhhy-        
          ${White}.+y' ${Green}'://++++++++++++++++++++++++' ${Yellow}':yhhhhyo:'         
        ${White}-yNd. ${Green}'/+++++++++++++++++++++++++++//' ${Yellow}.+yo:' ${White}'::        
       ${White}oNMh' ${Green}./++++++++++++++++++++++++++++++/:' '''' ${White}'mMh.      
      ${White}-MMM:  ${Green}/+++++++++++++++++++++++++++++++++-.:/+:  ${White}yMMs      
      ${White}-MMMs  ${Green}./++++++++++++++++++++++++++++++++++++/' ${White}.mMMy      
      ${White}'NMMMy. ${Green}'-/+++++++++++++++++++++++++++++++/:.  ${White}:dMMMo      
       ${White}+MMMMNy:' ${Green}'.:///++++++++++++++++++++//:-.' ${White}./hMMMMN'      
       ${White}-MMMMMMMmy+-.${Green}''''.---::::::::::--..''''${White}.:ohNMMMMMMy       
        ${White}sNMMMMMMMMMmdhs+/:${Green}--..........--${White}:/oyhmNMMMMMMMMMd-       
         ${White}.+dNMMMMMMMMMMMMMMNNmmmmmmmNNNMMMMMMMMMMMMMMmy:'        
            ${White}./sdNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNmho:'           
          ${White}'     .:+shmmNNMMMMMMMMMMMMMMMMNNmdyo/-'               
          ${White}.o:.       '.-::/+ossssssso++/:-.'       '-/'          
           ${White}.ymh+-.'                           ''./ydy.           
             ${White}/dMMNdyo/-.''''         ''''.-:+shmMNh:             
               ${White}:yNMMMMMMNmdhhyyyyyyyhhdmNNMMMMMNy:               
                 ${White}':sdNNMMMMMMMMMMMMMMMMMMMNNds:'                 
                     ${White}'-/+syhdmNNNNNNmdhyo/-'                     

                                                                      
                         Installation Menu\n                ${Bold}Guacamole Remote Desktop Gateway ${GUACA_VER}\n" && tput sgr0

echo -n "${Blue} Enter the root password for MariaDB: "
  read MYSQL_PASSWD
echo -n "${Blue} Enter the Guacamole DB name: "
  read DB_NAME
echo -n "${Blue} Enter the Guacamole DB username: "
  read DB_USER
echo -n "${Blue} Enter the Guacamole DB password: "
  read DB_PASSWD
echo -n "${Blue} Enter the Java KeyStore password (least 6 characters): "
  read JKSTORE_PASSWD

tput sgr0

progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%c' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}



echo -e "\nStarting...\nPreparing ingredients...\n"; echo -e "\nStarting...\nPreparing ingredients...\n" >> $logfile  2>&1

sleep 1 | echo -e "\nSearching for EPEL Repository ......";echo -e "\nSearching for EPEL Repository ......" >> $logfile  2>&1
rpm -qa | grep epel-release
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
	sleep 1 | echo -e "No need to install EPEL repository!"; echo -e "No need to install EPEL repository!" >> $logfile  2>&1
else
	sleep 1 | echo -e "\nIs necessary to install the EPEL repositories\nInstalling..."; echo -e "\nIs necessary to install the EPEL repositories\nInstalling..." >> $logfile  2>&1
	rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-${CENTOS_VER}.noarch.rpm
fi

sleep 1 | echo -e "\nUpdating CentOS...\n"; echo -e "\nUpdating CentOS...\n" >> $logfile  2>&1
yum update -y

sleep 1 | echo -e "\nInstalling Dependencies...\n"; echo -e "\nInstalling Dependencies...\n" >> $logfile  2>&1
yum install -y wget pv dialog gcc cairo-devel libpng-devel libjpeg-devel uuid-devel freerdp-devel pango-devel libssh2-devel libtelnet-devel libvncserver-devel pulseaudio-libs-devel openssl-devel libvorbis-devel tomcat mariadb mariadb-server gnu-free-mono-fonts

sleep 1 | echo -e "\nCreating Directories...\n" | pv -qL 25; echo -e "\nCreating Directories...\n" >> $logfile  2>&1
rm -fr ${INSTALL_DIR}
mkdir -vp ${INSTALL_DIR}client >> $logfile 2>&1 && cd ${INSTALL_DIR}
mkdir -v /etc/guacamole >> $logfile  2>&1
mkdir -v /usr/share/tomcat/.guacamole >> $logfile  2>&1
mkdir -vp ${LIB_DIR}classpath >> $logfile  2>&1

sleep 1 | echo -e "\nDownloading Guacamole packages for installation...\n" | pv -qL 25; echo -e "\nDownloading Guacamole packages for installation...\n" >> $logfile  2>&1
wget --progress=bar:force ${GUACA_URL}source/${GUACA_SERVER}.tar.gz 2>&1 | progressfilt
#wget --progress=bar:force ${GUACA_URL}source/${GUACA_CLIENT}.tar.gz 2>&1 | progressfilt
wget --progress=bar:force ${GUACA_URL}binary/${GUACA_CLIENT}.war -O ${INSTALL_DIR}client/guacamole.war 2>&1 | progressfilt
wget --progress=bar:force ${GUACA_URL}extensions/${GUACA_JDBC}.tar.gz 2>&1 | progressfilt
wget --progress=bar:force ${MYSQ_CONNECTOR_URL}${MYSQL_CONNECTOR}.tar.gz 2>&1 | progressfilt

sleep 1 | echo -e "\nDerompessing Guacamole Server Source...\n" | pv -qL 25; echo -e "\nDerompessing Guacamole Server Source...\n" >> $logfile  2>&1
pv ${GUACA_SERVER}.tar.gz | tar xzf - && rm -f ${GUACA_SERVER}.tar.gz
mv ${GUACA_SERVER} server

#sleep 1 | echo -e "\nDerompessing Guacamole Client...\n" | pv -qL 25
#pv ${GUACA_CLIENT}.tar.gz | tar xzf - && rm -f ${GUACA_CLIENT}.tar.gz
#mv ${GUACA_CLIENT} client

sleep 1 | echo -e "\nDecrompressing Guacamole JDBC Extension...\n" | pv -qL 25; echo -e "\nDecrompressing Guacamole JDBC Extension...\n" >> $logfile  2>&1
pv ${GUACA_JDBC}.tar.gz | tar xzf - && rm -f ${GUACA_JDBC}.tar.gz
mv ${GUACA_JDBC} extension

sleep 1 | echo -e "\nDecompressing MySQL Connector...\n" | pv -qL 25; echo -e "\nDecompressing MySQL Connector...\n" >> $logfile  2>&1
pv ${MYSQL_CONNECTOR}.tar.gz | tar xzf - && rm -f ${MYSQL_CONNECTOR}.tar.gz

sleep 1 | echo -e "\nCompiling Gucamole Server...\n" | pv -qL 25; echo -e "\nCompiling Gucamole Server...\n" >> $logfile  2>&1
cd server
./configure --with-init-dir=/etc/init.d
make
sleep 1 && make install
sleep 1 && ldconfig
cd ..

# sleep 1 | echo -e "\nCopiling Gucamole Client...\n" | pv -qL 25
# cd client
# mvn package
# cp guacamole/doc/example/guacamole.properties /etc/guacamole/
# cp guacamole/doc/example/user-mapping.xml /etc/guacamole/

sleep 1 | echo -e "\nCopiling Gucamole Client...\n" | pv -qL 25; echo -e "\nCopiling Gucamole Client...\n" >> $logfile  2>&1
cp -v client/guacamole.war ${LIB_DIR}guacamole.war

sleep 1 | echo -e "\nMaking Guacamole configurtion files...\n" | pv -qL 25; echo -e "\nMaking Guacamole configurtion files...\n" >> $logfile  2>&1
echo "# Hostname and port of guacamole proxy
guacd-hostname: ${SERVER_HOSTNAME}
guacd-port:     ${GUACA_PORT}

lib-directory: ${LIB_DIR}classpath/

# Auth provider class
auth-provider: net.sourceforge.guacamole.net.auth.mysql.MySQLAuthenticationProvider

# MySQL properties
mysql-hostname: ${SERVER_HOSTNAME}
mysql-port: ${MYSQL_PORT}
mysql-database: ${DB_NAME}
mysql-username: ${DB_USER}
mysql-password: ${DB_PASSWD}
mysql-disallow-duplicate-connections: false" > /etc/guacamole/${GUACA_CONF}

sleep 1 | echo -e "\nMaking Guacamole simbolic links...\n" | pv -qL 25; echo -e "\nMaking Guacamole simbolic links...\n" >> $logfile  2>&1
ln -vs ${LIB_DIR}guacamole.war /var/lib/tomcat/webapps
ln -vs /etc/guacamole/${GUACA_CONF} /usr/share/tomcat/.guacamole/

sleep 1 | echo -e "\nCopying Guacamole JDBC Extension to Lib Dir...\n" | pv -qL 25; echo -e "\nCopying Guacamole JDBC Extension to Lib Dir...\n" >> $logfile  2>&1
cp -v extension/mysql/guacamole-auth-jdbc-mysql-${GUACA_VER}.jar ${LIB_DIR}classpath/ || exit 1

sleep 1 | echo -e "\nCopying MySQL Connector to Lib Dir...\n" | pv -qL 25; echo -e "\nCopying MySQL Connector to Lib Dir...\n" >> $logfile  2>&1
cp -v mysql-connector-java-${MYSQL_CONNECTOR_VER}/mysql-connector-java-${MYSQL_CONNECTOR_VER}-bin.jar ${LIB_DIR}/classpath/ || exit 1

sleep 1 | echo -e "\nSetting MariaDB Service...\n" | pv -qL 25; echo -e "\nSetting MariaDB Service...\n" >> $logfile  2>&1
systemctl enable mariadb.service
systemctl restart mariadb.service

sleep 1 | echo -e "\nSetting Root Password for MariaDB...\n" | pv -qL 25; echo -e "\nSetting Root Password for MariaDB...\n" >> $logfile  2>&1
mysqladmin -u root password ${MYSQL_PASSWD} || exit 1

sleep 1 | echo -e "\nCreating BD & User for Guacamole...\n" | pv -qL 25; echo -e "\nCreating BD & User for Guacamole...\n" >> $logfile  2>&1
mysql -u root -p${MYSQL_PASSWD} -e "CREATE DATABASE ${DB_NAME};" || exit 1
mysql -u root -p${MYSQL_PASSWD} -e "GRANT SELECT,INSERT,UPDATE,DELETE ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWD}';" || exit 1
mysql -u root -p${MYSQL_PASSWD} -e "FLUSH PRIVILEGES;" || exit 1

sleep 1 | echo -e "\nCreating Guacamole Tables...\n" | pv -qL 25; echo -e "\nCreating Guacamole Tables...\n" >> $logfile  2>&1
cat extension/mysql/schema/*.sql | mysql -u root -p${MYSQL_PASSWD} -D ${DB_NAME}

sleep 1 | echo -e "\nSetting Tomcat Server\n" | pv -qL 25; echo -e "\nSetting Tomcat Server\n" >> $logfile  2>&1
sed -i '72i URIEncoding="UTF-8"' /etc/tomcat/server.xml
sed -i '91i <Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true" \
               maxThreads="150" scheme="https" secure="true" \
               clientAuth="false" sslProtocol="TLS" \
               keystoreFile="/var/lib/tomcat/webapps/.keystore" \
               keystorePass="JKSTORE_PASSWD" \
               URIEncoding="UTF-8" />' /etc/tomcat/server.xml
sed -i "s/JKSTORE_PASSWD/${JKSTORE_PASSWD}/g" /etc/tomcat/server.xml

sleep 1 | echo -e "\nPlease complete the Wizard for the Java KeyStore\n" | pv -qL 25; echo -e "\nPlease complete the Wizard for the Java KeyStore\n" >> $logfile  2>&1
keytool -genkey -alias Guacamole -keyalg RSA -keystore /var/lib/tomcat/webapps/.keystore -storepass ${JKSTORE_PASSWD} -keypass ${JKSTORE_PASSWD}

sleep 1 | echo -e "\nSetting Tomcat Service...\n" | pv -qL 25; echo -e "\nSetting Tomcat Service...\n" >> $logfile  2>&1
systemctl enable tomcat.service
systemctl start tomcat.service

sleep 1 | echo -e "\nSetting Guacamole Service...\n" | pv -qL 25; echo -e "\nSetting Guacamole Service...\n" >> $logfile  2>&1
chkconfig guacd on
systemctl start guacd.service

sleep 1 | echo -e "\nSetting Firewall...\nOpening ports 8080 and 8443...\n" | pv -qL 25; echo -e "\nSetting Firewall...\nOpening ports 8080 and 8443...\n" >> $logfile  2>&1
firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --permanent --zone=public --add-port=8443/tcp
firewall-cmd --reload


sleep 1 | echo -e "\nFinished Successfully\n" | pv -qL 25; echo -e "\nFinished Successfully\n" >> $logfile  2>&1
sleep 1 | echo -e "\nYou can check the log file ${logfile}\n" | pv -qL 25; echo -e "\nYou can check the log file ${logfile}\n" >> $logfile  2>&1
sleep 1 | echo -e "\nTo manage the Guacamole GW go to http://<IP>:8080/guacamole/ or https://<IP>:8443/guacamole/\n" | pv -qL 25; echo -e "\nTo manage the Guacamole GW go to http://<IP>:8080/guacamole/ or https://<IP>:8443/guacamole/\n" >> $logfile  2>&1

sleep 1 | echo -e "\nIf you have any suggestions please write to: correo@nacimientohernan.com.ar\n" | pv -qL 25; echo -e "\nIf you have any suggestions please write to: correo@nacimientohernan.com.ar\n" >> $logfile  2>&1
