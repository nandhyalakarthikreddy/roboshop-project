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
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling the default redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling the updated version"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing the redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c  protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connection to redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enable the redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "starting the redis"

