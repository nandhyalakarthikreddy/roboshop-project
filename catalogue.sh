#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

LOG_FOLDER="/var/log/shell-roboshop"
FILE_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$FILE_NAME.log"
MONGODB_HOST=mongodb.nkrdev.space
SCRIPT_DIR=$PWD
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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Addding system user"
else
    echo -e "Already exists $Y skipping $N"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading catalogue application"

cd /app 
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "removing exissting code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip the file"

npm install  &>>$LOG_FILE
VALIDATE $? "installing the library"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Adding catalogue repo"

systemctl daemon-reload
VALIDATE $? "Reload the file"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enable the catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "Adding mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing the mongodb"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "load catalogue products"

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"