#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
mkdir -p data logs
#log function
logIT() { 
    echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') $1" >> logs/lab3.log 
}
#cleanup function
cleanUP() {
    logIT "LAB3_END"
}

#Lab Start
logIT "LAB3_START"
trap cleanUP EXIT
#requirements check
if ! command -v curl; then
    echo "curl not found"
    exit 1
elif ! command -v jq; then
    echo "jq not found"
    exit 1
else
    logIT "BASH_OK"
fi

#variables
jokeURL="https://icanhazdadjoke.com/"
sJOKE=$(curl -sS -H "Accept: application/json" -o data/dad_joke.json -w "%{http_code}" "$jokeURL")

#success check
if [ "$sJOKE" -ne 200 ]; then
    logIT "CURL_JOKE_FAIL"
    exit 1
else
    logIT "CURL_JOKE_OK"
fi

jq -r '.id, .joke' data/dad_joke.json > data/dad_joke.txt
logIT "JQ_JOKE_OK"

deckURL="https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"
sDECK=$(curl -sS -o data/deck_create.json -w "%{http_code}" "$deckURL")

if [ "$sDECK" -ne 200 ]; then
    logIT "DECK_CREATE_FAIL"
    exit 1
else
    logIT "DECK_CREATE_OK"
fi

myDECK=$(jq -r '.deck_id' data/deck_create.json)
drawURL="https://deckofcardsapi.com/api/deck/$myDECK/draw/?count=2"
sDRAW=$(curl -sS -o data/deck_draw.json -w "%{http_code}" "$drawURL")

if [ "$sDRAW" -ne 200 ]; then
    logIT "DECK_DRAW_FAIL"
    exit 1
else
    logIT "DECK_DRAW_OK"
fi

jq -r '.cards[] | "\(.value) of \(.suit)"' data/deck_draw.json > data/deck_summary.txt
echo "Cards remaining: $(jq -r '.remaining' data/deck_draw.json)" >> data/deck_summary.txt
logIT "JQ_DECK_OK"
