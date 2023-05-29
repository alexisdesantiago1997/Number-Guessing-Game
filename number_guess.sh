#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#function to check if input is an integer
check_guess(){
  if [[ "$GUESS" =~ ^[0-9]+$ ]]
  then
    ((NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1))
    if [[ $GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
    #if number is lower than guess
    if [[ $GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
}

#Guess between 1 and 1000
#NUMBER=$(($RANDOM % 1000 + 1))

#Guess between 1 and 10
NUMBER=$(($RANDOM % 10 + 1))


echo "Enter your username:"

read USERNAME

PLAYER=$($PSQL "SELECT * FROM players WHERE username='$USERNAME'")

if [[ -z $PLAYER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0
read GUESS

check_guess


while [[ $GUESS != $NUMBER ]]
do
  read GUESS
  check_guess
  #echo "Number of guesses: $NUMBER_OF_GUESSES"
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"

#if new player
if [[ $GAMES_PLAYED == 0 ]]
then
  INSERT_NEW_PLAYER_RESULTS=$($PSQL "INSERT INTO players (username, games_played,best_game) VALUES('$USERNAME',1,$NUMBER_OF_GUESSES)")
else
  ((GAMES_PLAYED=GAMES_PLAYED+1))
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  #if new best game
  OLD_BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")
  if [[ $NUMBER_OF_GUESSES -lt $OLD_BEST_GAME ]]
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
  fi
fi

#save player and game info
