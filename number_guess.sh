#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#PSQL="psql --username=postgres --dbname=number_guess -t --no-align -c"

if [ $? -eq 0 ]; then
  echo "psql code executed successfully"
else
  echo "psql code failed with exit code: $?"
fi

GUESS_LOOP() {
 # Generate random secret number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=1   

 while [[ $GUESS != $SECRET_NUMBER ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
    else
      if [[ $GUESS > $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        read GUESS
      else
        echo "It's higher than that, guess again:"
        read GUESS
      fi
      ((GUESS_COUNT++))
    fi
  done
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
ADD_NEW_DATA=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $GUESS_COUNT)") 
}

# Get username
echo "Enter your username:"
read USERNAME

# Check if username exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
  then
  # New user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Returning user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."     
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

GUESS_LOOP

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

###
exit 0