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
START_TIME=$(date +%s)
mkdir -p $LOG_FOLDER

echo "script started and executed at :  $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e " $R Error :: please run the script by using root cart $N "
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
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop &>>$LOG_FILE
    VALIDATE $? "Addding system cart"
else
    echo -e "Already exists $Y skipping $N"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading cart application"

cd /app 
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "removing exissting code"

unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "unzip the file"

npm install  &>>$LOG_FILE
VALIDATE $? "installing the library"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service 
VALIDATE $? "Adding cart repo"

systemctl daemon-reload
VALIDATE $? "Reload the file"

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "enable the cart"

systemctl restart cart
VALIDATE $? "Restarting cart"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo -e "script executed in :: $Y $TOTAL_TIME seconds $N"