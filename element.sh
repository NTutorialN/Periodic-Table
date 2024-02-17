#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align --tuples-only -c"

NOT_FOUND() {
  echo "I could not find that element in the database."
  exit
}


# Check if there is input
if [[ -z $1 ]]
then
  # Exit
  echo "Please provide an element as an argument."
  exit
fi

# If input is Atomic Number
if [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$1
else
  # If input is Element Symbol
  if [[ ${#1} -le 2 ]]
  then
    # Get Atomic Number from Symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1';")
  # Treat input as Element Name
  else
    # Get Atomic Number from Name
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1';")
  fi
fi

if [[ -z $ATOMIC_NUMBER ]]
then
  NOT_FOUND
fi

# Get Properties using Atomic Number
PROPERTIES=$($PSQL "SELECT name, symbol, atomic_mass, melting_point_celsius, boiling_point_celsius, type 
                    FROM properties 
                    INNER JOIN elements USING(atomic_number)
                    INNER JOIN types USING(type_id)
                    WHERE atomic_number = $ATOMIC_NUMBER;")
if [[ -z $PROPERTIES ]]
then
  NOT_FOUND
fi

ELEMENT_NAME=$(echo $PROPERTIES | cut -d "|" -f 1)
ELEMENT_SYMBOL=$(echo $PROPERTIES | cut -d "|" -f 2)

MASS=$(echo $PROPERTIES | cut -d "|" -f 3)
MELT=$(echo $PROPERTIES | cut -d "|" -f 4)
BOIL=$(echo $PROPERTIES | cut -d "|" -f 5)

TYPE=$(echo $PROPERTIES | cut -d "|" -f 6)

# Print Properties
echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $TYPE, with a mass of $MASS amu. $ELEMENT_NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
