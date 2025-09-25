#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
mkdir -p $LOGS_FOLDER
echo " script started executed at : $(date)" | tee -a $LOGS_FILE

if [ $USERID -ne 0 ]; then
    echo -e "$R Error $N :: please run the script by using root user"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R Error :: failed to install $2 $N " | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$G installing the $2 server is success $N" | tee -a $LOGS_FILE
fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"

dnf insatll mongodb -y &>>$LOGS_FILE
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable MongoDb"
systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Start MongoDb"