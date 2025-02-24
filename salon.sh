#! /bin/bash

PSQL="psql --username=postgres --dbname=salon --tuples-only -c"

echo -e "\nWelcome to the Salon! Here are our services:\n"

# Display the services
SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Prompt for service
echo -e "\nPlease enter the service number you want:"
read SERVICE_ID_SELECTED

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

while [[ -z $SERVICE_NAME ]]
do
  echo -e "\nInvalid selection. Please choose again:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

# Prompt for phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nYou are a new customer! Please enter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
fi

# Prompt for time
echo -e "\nEnter the time for your appointment:"
read SERVICE_TIME

INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
