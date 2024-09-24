#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# login
echo Enter your username:
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
  then
   echo Welcome, $USERNAME! It looks like this is your first time here.
    # create new user
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  else
  # greet returning
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) from games WHERE user_id = $USER_ID")
    echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.

fi



# generate number
SECRET_NUMBER=$(( RANDOM % 999 + 1 ))

NEW_GAME=$($PSQL "INSERT INTO games(user_id,secret_number) VALUES($USER_ID,$SECRET_NUMBER)") 
GAME_ID=$($PSQL "SELECT MAX(game_id) FROM games WHERE user_id = $USER_ID")
ATTEMPT=0

function WIN(){
  RECORD_ATTEMPTS=$($PSQL "UPDATE games SET number_of_guesses = $ATTEMPT WHERE game_id = $GAME_ID")
  NUMBER_OF_GUESSES=$($PSQL "SELECT number_of_guesses FROM games WHERE game_id=$GAME_ID")
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

function GET_GUESS(){
  (( ATTEMPT++ ))
  read GUESS

  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS = $SECRET_NUMBER ]]
    then
        WIN
    else
      if [[ $SECRET_NUMBER -lt $GUESS ]]
        then
          echo  "It's lower than that, guess again:"
          GET_GUESS
        else
          echo "It's higher than that, guess again:"
          GET_GUESS
        fi
    fi
  else  
    echo "That is not an integer, guess again:"
    GET_GUESS
 fi
}


echo Guess the secret number between 1 and 1000:
GET_GUESS



