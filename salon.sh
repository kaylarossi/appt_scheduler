#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

SERVICE_MENU(){
  #if something is entered, print the entry
if [[ $1 ]]
then
  echo -e "\n$1"
fi
#get available services
SERVICE_ID_AVAILABLE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
#display services
echo -e "\nServices available"
  echo "$SERVICE_ID_AVAILABLE" | while read SERVICE_ID BAR NAME 
do
  echo "$SERVICE_ID) $NAME"
done
BOOKING
}
BOOKING(){
  #ask for service
echo -e "\nWhich would you like to schedule?"
read SERVICE_ID_SELECTED
#check if service provided
SERVICE_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
#if not a service
if [[ -z $SERVICE_AVAIL ]]
then
  #show list again
 SERVICE_MENU "I could not find that service, what would you like today?"
else
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ |/"/')
#get customer info 
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nI don't have record of that phone number. What's your name?"
    read CUSTOMER_NAME
    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  #get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #ask for appt time
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED?"
  read SERVICE_TIME
fi
EXIT
}

EXIT(){
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
  #add into appointments table
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  #return prompt of appointment
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}


SERVICE_MENU