#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  # if argument is passed, display to the user
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # display menu
  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"

  # read service selection
  read SERVICE_ID_SELECTED

  # if invalid service
  if [[ $SERVICE_ID_SELECTED -lt 1 || $SERVICE_ID_SELECTED -gt 5 ]]
  then
    # go to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # read phone number
    echo -e "\nWhat's your phone number?"

    read CUSTOMER_PHONE

    # get customer
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if not found
    if [[ -z $CUSTOMER_ID ]]
    then
      # read new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"

      read CUSTOMER_NAME

      # insert customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      # get customer
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    
    # read time
    echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"

    read SERVICE_TIME

    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')

    # display confirmation to user
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# call main menu
MAIN_MENU