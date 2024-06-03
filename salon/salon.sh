#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU () {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "\n~~~~~ MY SALON ~~~~~\n"

  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES" | while read ID BAR NAME
  do
    echo "$ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  # check if service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g')
  # if service not found
  if [[ -z $SERVICE_NAME ]]; then
    # return to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')

    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_ID_FORMATTED=$(echo "$CUSTOMER_ID" | sed -r 's/^ *| *$//g')
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE_NAME_FORMATTED'")
    SERVICE_ID_FORMATTED=$(echo "$SERVICE_ID" | sed -r 's/^ *| *$//g')
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID_FORMATTED, $SERVICE_ID_FORMATTED)")

    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?"