#!/bin/bash

DEPENDENCIES=("curl")
MISSING=()

for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "\033[1;33m[!] Deteksi package yang belum terinstall:\033[0m"
    for pkg in "${MISSING[@]}"; do
        echo -e "\033[0;31m - $pkg (belum ada)\033[0m"
    done
    echo -e "\n\033[0;36mMenginstall package yang dibutuhkan dalam 3 detik...\033[0m"
    for i in {1..3}; do
        echo -ne "\r\033[1;32m[•] Loading $i...\033[0m"
        sleep 1
    done
    echo ""

    pkg_mgr=""
    if command -v apt &> /dev/null; then
        pkg_mgr="apt"
    elif command -v pkg &> /dev/null; then
        pkg_mgr="pkg"
    elif command -v yum &> /dev/null; then
        pkg_mgr="yum"
    fi

    if [ -z "$pkg_mgr" ]; then
        echo -e "\033[0;31m[!] Gagal deteksi package manager. Install manual ya.\033[0m"
        exit 1
    fi

    for pkg in "${MISSING[@]}"; do
        echo -e "\033[1;34m[+] Installing $pkg...\033[0m"
        $pkg_mgr install -y "$pkg"
    done
fi

if test -t 1; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

function banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
 ___  ____   __    __  __    ____  ____  __    ____
/ __)(  _ \ /__\  (  \/  )  (_  _)( ___)(  )  ( ___)
\__ \ )___//(__)\  )    (     )(   )__)  )(__  )__)
(___/(__) (__)(__)(_/\/\_)   (__) (____)(____)(____)
EOF
    echo -e "${NC}"
    echo -e "${BLUE}   Telegram Bot Spammer Tool By ~ RenXploit${NC}"
    echo -e "${BLUE}            Spam terus brooo 🗿👍 ${NC}"
    echo -e "${CYAN}============================================${NC}"
}

function validate_integer() {
    local input="$1"
    if [[ "$input" =~ ^[1-9][0-9]*$ ]]; then
        echo 1
    else
        echo 0
    fi
}

function prompt_token() {
    while true; do
        read -p "Token Bot: " token
        if [[ -z "$token" ]]; then
            echo -e "${RED}Token tidak boleh kosong! Coba lagi.${NC}"
        else
            break
        fi
    done
}

function prompt_chat_id() {
    while true; do
        read -p "Chat ID: " chat_id
        if [[ -z "$chat_id" ]]; then
            echo -e "${RED}Chat ID tidak boleh kosong! Coba lagi.${NC}"
        elif ! [[ "$chat_id" =~ ^-?[0-9]+$ ]]; then
            echo -e "${RED}Chat ID harus berupa angka! Coba lagi.${NC}"
        else
            break
        fi
    done
}

function prompt_threads() {
    while true; do
        read -p "Jumlah Threads (misal 1/detik): " threads
        valid=$(validate_integer "$threads")
        if [[ "$valid" -eq 1 ]]; then
            break
        else
            echo -e "${RED}Jumlah Threads harus berupa bilangan bulat positif! Coba lagi.${NC}"
        fi
    done
}

function prompt_pesan_jumlah() {
    while true; do
        read -p "Pesan: " message
        if [[ -z "$message" ]]; then
            echo -e "${RED}Pesan tidak boleh kosong! Coba lagi.${NC}"
        else
            break
        fi
    done

    while true; do
        read -p "Jumlah Pesan (angka): " jumlah
        valid=$(validate_integer "$jumlah")
        if [[ "$valid" -eq 1 ]]; then
            break
        else
            echo -e "${RED}Jumlah Pesan harus berupa bilangan bulat positif! Coba lagi.${NC}"
        fi
    done
}

function send_message() {
    local token="$1"
    local chat_id="$2"
    local message="$3"
    curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
         -d "chat_id=${chat_id}" \
         -d "text=${message}" > /dev/null
}

function send_messages_concurrent() {
    local token="$1"
    local chat_id="$2"
    local message="$3"
    local jumlah="$4"
    local threads="$5"
    local count=0

    echo -e "\n${YELLOW}Mengirim ${jumlah} pesan dengan ${threads} thread...${NC}"
    for (( i=1; i<=jumlah; i++ )); do
        send_message "$token" "$chat_id" "$message" &
        echo -e "${GREEN}[${i}/${jumlah}] Pesan terkirim!${NC}"
        ((count++))
        if (( count % threads == 0 )); then
            wait
        fi
    done
    wait
    echo -e "\n${CYAN}Selesai mengirim ${jumlah} pesan.${NC}"
}

global_token=""
global_chat_id=""
global_threads=""

while true; do
    banner

    if [[ -z "$global_token" || -z "$global_chat_id" || -z "$global_threads" ]]; then
        echo -e "${BLUE}Input data lengkap terlebih dahulu:${NC}"
        prompt_token
        global_token="$token"
        prompt_chat_id
        global_chat_id="$chat_id"
        prompt_threads
        global_threads="$threads"
    fi

    prompt_pesan_jumlah
    send_messages_concurrent "$global_token" "$global_chat_id" "$message" "$jumlah" "$global_threads"

    echo -e "\n${CYAN}Pilih opsi selanjutnya:${NC}"
    echo -e "${CYAN}[u] Input ulang data lengkap (token, chat id, threads)${NC}"
    echo -e "${CYAN}[y] Kirim ulang pesan dengan data sebelumnya${NC}"
    echo -e "${CYAN}[n] Keluar dari script${NC}"

    while true; do
        read -p "Opsi (u/y/n): " opsi
        case "$opsi" in
            n)
                echo -e "${RED}Script dihentikan. Sampai jumpa!${NC}"
                exit 0
                ;;
            u)
                global_token=""
                global_chat_id=""
                global_threads=""
                break
                ;;
            y)
                break
                ;;
            *)
                echo -e "${RED}Opsi tidak valid! Masukkan u, y, atau n.${NC}"
                ;;
        esac
    done
done
