#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RIGHT_GUESS_F() {
  GAMES_PLAYED=$((GAMES_PLAYED + 1))
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
  INSERT_INTO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")
  if (($BEST_GAME == 0)) || (($BEST_GAME>$GUESS_COUNT))
  then
    UPDATE_USERS=$($PSQL "UPDATE users SET best_game=$GUESS_COUNT, games_played=$GAMES_PLAYED WHERE user_id = $USER_ID")
  else
    UPDATE_USERS=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id = $USER_ID")
  fi
  echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
}

GAME_F() {
  local PROMPT=$1
  echo "$PROMPT"
  read GUESS
  if [[ $GUESS =~ ^[1-9][0-9]?[0-9]?0?$ ]]
  then
    GUESS_COUNT=$((GUESS_COUNT + 1))
    case $(( GUESS - SECRET_NUMBER )) in 
      0) RIGHT_GUESS_F ;;
      -*) GAME_F "It's higher than that, guess again:" ;;
      *) GAME_F "It's lower than that, guess again:" ;;
    esac
  else
    GUESS_COUNT=$((GUESS_COUNT + 1))
    GAME_F "That is not an integer, guess again: "
  fi
}

SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo "Enter your username: "
read USERNAME
USERNAME_IN_DB=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")
if [[ -z $USERNAME_IN_DB ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_INTO_USERS=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES ('$USERNAME', 0, 0)")
  GAMES_PLAYED=0
  BEST_GAME=0
  GUESS_COUNT=0
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME'")
  GUESS_COUNT=0
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GAME_F "Guess the secret number between 1 and 1000: "
