#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

LOG_FOLDER="/var/log/shell-roboshop"
FILE_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$FILE_NAME.log"
mkdir -p $LOG_FOLDER

echo "script started and executed at :  $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e " $R Error :: please run the script by using root user $N "
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R Error :: Failed to $2 server $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G $2 server $N" | tee -a $LOG_FILE
fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongodb"

systemctl enable mongod 
VALIDATE $? "Enabling mongodb"

systemctl start mongod 
VALIDATE $? "Starting mongodb"


