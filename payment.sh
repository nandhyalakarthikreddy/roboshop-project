#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USERID=$(id -u)

LOG_FOLDER="/var/log/shell-roboshop"
FILE_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOG_FOLDER/$FILE_NAME.log"
START_TIME=$(date +%s)
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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Addding system user"
else
    echo -e "Already exists $Y skipping $N"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading payment application"

cd /app 
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "removing exissting code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzip the file"

pip3 install -r requirements.txt &>>$LOG_FILE

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE

systemctl daemon-reload &>>$LOG_FILE

systemctl enable payment &>>$LOG_FILE

systemctl start payment &>>$LOG_FILE


END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo -e "script executed in :: $Y $TOTAL_TIME seconds $N"