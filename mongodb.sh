#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/home/ec2-user/shell-roboshop-p/logs"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R='\e[31m'
Y='\e[32m'
G='\e[33m'
N='\e[0m'

mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]; then
  echo -e "$R Please run the script with root user access $N" | tee -a $LOGS_FILE
  exit 1
fi

VALIDATE() {
  if [ $1 -ne 0 ]; then
    echo -e "$2...$R FAILURE $N" | tee -a $LOGS_FILE
    exit 1
  else
    echo -e "$2..$G SUCCESS $N" | tee -a $LOGS_FILE
  fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo.repo"

dnf install mongodb-org -y 
VALIDATE $? "Installing mongodb"

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "Enable and starting mongod"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $? "Changing private address in conf file"

systemctl restart mongod
VALIDATE $? "Restarting mongod"
