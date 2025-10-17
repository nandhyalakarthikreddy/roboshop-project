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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling the rabbitmq-server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting the server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "Adding the user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Setting up the root permissions"




END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME-$START_TIME))
echo -e "script executed in :: $Y $TOTAL_TIME seconds $N"