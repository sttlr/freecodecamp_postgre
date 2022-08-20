#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"
#($PSQL "TRUNCATE customers, appointments")

echo -e "\n~~~~~ DA SAUL's NAIL SALON ~~~~~\n"


function main_menu {
  if [[ $1 ]]; then
    echo -e "\n$1"
  else
    echo -e "\nDid you know that you have rights? Whaddaya want?\n"
  fi

  # print services
  echo -e "$($PSQL 'SELECT service_id, name FROM services')" |  while IFS=' | ' read ID NAME
  do
    echo "$ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    main_menu "heyya, use a number!"
  elif [[ ! $($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED") ]]; then
    main_menu "there is no such service, ya see??"
  else
    service_menu $SERVICE_ID_SELECTED
  fi
}


function service_menu {
  SERVICE_ID_SELECTED=$1
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  echo -e "\nI need your phone to idenfity ya:"

  read CUSTOMER_PHONE

  if [[ ! $($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") ]]; then
    register_menu $CUSTOMER_PHONE
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)
  
  echo -e "\nima always free, at what time wouldya to $SERVICE_NAME *cuh-cuh* launder your maney, $CUSTOMER_NAME?"
  
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}


function register_menu {
  CUSTOMER_PHONE=$1

  echo -e "\nha, new one, NAME HERE?"

  read CUSTOMER_NAME

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
}

main_menu