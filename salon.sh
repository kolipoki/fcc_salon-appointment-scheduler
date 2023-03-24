#!/bin/bash

# Connect to salon  database
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Title
echo -e "\n~~~~~ MY SALON ~~~~~"
# Welcome text
echo -e "\nWelcome to My Salon, how can I help you?\n"

# Main menu implementation
MAIN_MENU() {
  # Make a variable to be able to pass an argument with MAIN_MENU function if I call with an argument
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # List services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # Pipe the output to a while loop which reads each line
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  # Read input
  read SERVICE_ID_SELECTED
  # Check if input is a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Input is not a number jump back to main menu with a message
    INVALID_SERVICE_ID
  else
    # Input is valid
    VALID_SERVICE_ID
  fi
}

# Implementation if the selection is valid
VALID_SERVICE_ID() {
  # Check the selection in the services table
    SELECTED_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    # If it doesn't exist jump back to main menu with a message
    if [[ -z $SELECTED_SERVICE_ID ]]
    then
      INVALID_SERVICE_ID
    else
      BOOKING_PROCESS
    fi
}

# Implementation if the selection is invalid
INVALID_SERVICE_ID() {
  MAIN_MENU "I could not find that service. What would you like today?"
}

BOOKING_PROCESS() {
  # If it is right ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # Check phone number in the customers table
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # Check if there is a match with the number
  if [[ -z $CUSTOMER_NAME ]]
  then
    NEW_USER
    SERVICE_BOOKING
  else
    SERVICE_BOOKING
  fi
  CONFIRMATION
}

NEW_USER() {
  # If it is not found ask for name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  # Insert into the customers table the name and the phone number
  INSERT_PHONE_NUMBER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
}

SERVICE_BOOKING() {
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id='$SELECTED_SERVICE_ID'")
  # Ask for time
  echo -e "\nWhat time would you like your $(echo $SELECTED_SERVICE| sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME
  # Get Customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # Insert into appointements table
  INSERT_APPOINTMENT_TIME=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SELECTED_SERVICE_ID', '$SERVICE_TIME')")
}

CONFIRMATION() {
  # Confirmation
  echo -e "\nI have put you down for a $(echo $SELECTED_SERVICE| sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU
