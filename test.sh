#!/bin/bash

TARGET="$1"
WORDLIST="$2"
LEVELS="$3"
RESPONSE_CODES="$4"
THREADS="10"
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;36m"
NC="\033[0m"

if [ -z "$TARGET" ]; then
    echo -e "${RED}Error: Provide a URL"
    exit 1
fi

if [ -z "$WORDLIST" ]; then
    echo -e "${RED}Error: You did not provide a wordlist."
    exit 2
fi

if [ ! -e "$WORDLIST" ]; then
    echo -e "${RED}Error: Wordlist file doesn't exist."
    exit 3
fi

if [ -z "$LEVELS" ]; then
    echo -e "${RED}Error: Provide the number of levels to recurse"
    exit 4
elif [[ ! "$LEVELS" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Provide me with an integer"
    exit 5
fi

if [ -z "$RESPONSE_CODES" ]; then
    echo -e "${RED}Error: You did not provide with the RESPONSE_CODES."
    echo
    RESPONSE_CODES="200,301,307,401,403"
    echo -e "${BLUE}Using ${RESPONSE_CODES}, instead"
    exit 6
fi

    echo -e "${BLUE}[+] Target = $TARGET"
    echo -e "${BLUE}[+] Response_codes = ${RESPONSE_CODES}"


run_gobuster() {
    local TARGET=$1
    local LEVEL=$2
    local NEXT_LEVEL=$((LEVEL + 1))

    #echo "[-] Level = $LEVEL"
    #echo "[+] Busting $TARGET"

    if [ "${LEVEL}" -lt "${LEVELS}" ]; then
        #echo -e "${BLUE}gobuster -f -q -e -k -r -t ${THREADS} -m dir -w "${WORDLIST}" -s "${RESPONSE_CODES}" -u ${TARGET}"
        gobuster dir -f -q -e -k -r -t ${THREADS} -w "${WORDLIST}" -s "${RESPONSE_CODES}" -u ${TARGET} | grep 'http.*Status: [234]' | sed 's/ (Status.*//' | while read HIT; do
            echo -e "${GREEN}[+] Found $HIT${NC}"
            run_gobuster ${HIT} ${NEXT_LEVEL}
        done
    fi
}


STATUS=$(curl -k -o /dev/null --silent --head --write-out '%{http_code}\n' "$TARGET")

if [ "$STATUS" -ge "100" -a "$STATUS" -lt "500" ]; then
    echo -e "${GREEN}[+] Found $TARGET${NC}"
    run_gobuster $TARGET 0
fi