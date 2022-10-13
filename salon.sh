#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
echo -e "$1"
#display services
GET_SERVICES=$($PSQL "SELECT * FROM services")
if [[ -z $GET_SERVICES ]]
then
  echo "No services available."
else
  echo "$GET_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  #choose service
  read SERVICE_ID_SELECTED
  #check that the service exists
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SELECTED_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    PHONE_NUMBER
  fi
fi
}

PHONE_NUMBER(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #check if phone number exists
  GET_PHONE=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $GET_PHONE ]]
  then
    #if unknown phone number, create customer
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER = $($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  else
    #if existing customer, get name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo $CUSTOMER_NAME
  fi
  echo -e "\nWhat time would you like your$SELECTED_SERVICE, $CUSTOMER_NAME?"
  read SERVICE_TIME
  MAKE_APPOINTMENT
}

MAKE_APPOINTMENT(){
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT = $($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a$SELECTED_SERVICE at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *//')."
}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"
