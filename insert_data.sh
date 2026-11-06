#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Limpar as tabelas antes de popular
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Ler o arquivo games.csv pulando a primeira linha (cabeçalho)
cat games.csv | tail -n +2 | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # 1. Verificar se o time vencedor já está cadastrado
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  
  # Se não estiver, insere na tabela teams
  if [[ -z $WINNER_ID ]]
  then
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
    # Recupera o ID gerado para o vencedor
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
  fi

  # 2. Verificar se o time oponente já está cadastrado
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  
  # Se não estiver, insere na tabela teams
  if [[ -z $OPPONENT_ID ]]
  then
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
    # Recupera o ID gerado para o oponente
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
  fi

  # 3. Inserir o jogo na tabela games
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
done