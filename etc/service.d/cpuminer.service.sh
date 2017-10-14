#!/data/data/com.termux/files/usr/bin/bash
##
##  Service file for CPU miner
##

## show service info for cpuminer when running 'service list'
if [ "${1}" == "--info" ]; then
    echo "CPU cryptocurrency miner daemon"
    exit 0
fi

# load config file
if [ ! -f "${PREFIX}/etc/conf.d/cpuminer.conf" ]; then
    echo "== WARNING: '${PREFIX}/etc/conf.d/cpuminer.conf' does not exist."
else
    source "${PREFIX}/etc/conf.d/cpuminer.conf"
fi

# set default config values
[ -z "${ALGORITHM}" ] && ALGORITHM="cryptonight-light"
[ -z "${MINING_SERVER_URL}" ] && MINING_SERVER_URL="stratum+tcp://mine.aeon-pool.com:3333"
[ -z "${USER}" ] && USER="Wmsqgdc61vTUdbSXPMA59kbBZyhs6mrxAKPaJ33rS9hG8PWR5uJLRS7b5dfyGDMCLt6eMvUw667auZvXCAqeSqGo31o3AXsei"
[ -z "${PASSWORD}" ] && PASSWORD="x"
[ -z "${THREADS}" ] && THREADS="4"
[ -z "${MAX_TEMP}" ] && MAX_TEMP="37"
[ -z "${LOG_FILE}" ] && LOG_FILE="/data/data/com.termux/files/usr/var/log/cpuminer.log"

# do checks
if ! grep -q -P '^\d+$' <(echo "${THREADS}"); then
    echo "== Error: invalid value set for 'THREADS'."
    exit 1
fi

if ! grep -q -P '^\d+$' <(echo "${MAX_TEMP}"); then
    echo "== Error: invalid value set for 'MAX_TEMP'."
    exit 1
fi

if [ ${MAX_TEMP} -gt 45 ] || [ ${MAX_TEMP} -lt 20 ]; then
    echo "== Error: invalid value set for 'MAX_TEMP'."
    exit 1
fi

###############################################################################
##
##  Service functions
##
###############################################################################

start_service()
{
    local CURRENT_PID

    CURRENT_PID=$(pgrep -u "${TERMUX_UID}" -f '^cpuminer .+')

    if [ ! -z "${CURRENT_PID}" ]; then
        echo "== CPU miner daemon is already running."
        exit 1
    else
        echo -n "== Starting CPU miner daemon... "

        if cpuminer --algo="${ALGORITHM}"          \
                    --url="${MINING_SERVER_URL}"   \
                    --user="${USER}"               \
                    --pass="${PASSWORD}"           \
                    --threads="${THREADS}"         \
                    --max-temp="${MAX_TEMP}"       \
                    --background >> "${LOG_FILE}" 2>&1; then
            echo "OK"
            exit 0
        else
            echo "FAIL"
            exit 1
        fi
    fi
}

stop_service()
{
    local CURRENT_PID

    CURRENT_PID=$(pgrep -u "${TERMUX_UID}" -f '^cpuminer .+')

    if [ ! -z "${CURRENT_PID}" ]; then
        echo -n "== Stopping CPU miner daemon... "
        sync
        if kill "${CURRENT_PID}" > /dev/null 2>&1; then
            echo "OK"
            exit 0
        else
            echo "FAIL"
            exit 1
        fi
    else
        echo "== CPU miner daemon is not running."
        exit 1
    fi
}

service_status()
{
    local CURRENT_PID

    CURRENT_PID=$(pgrep -u "${TERMUX_UID}" -f '^cpuminer .+')

    if [ ! -z "${CURRENT_PID}" ]; then
        echo "== CPU miner daemon is running, pid ${CURRENT_PID}."
    else
        echo "== CPU miner daemon is not running."
    fi
}

###############################################################################
##
##  Command line arguments handling
##
###############################################################################

if [ ! -z "${1}" ]; then
    case "${1}" in
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        status)
            service_status
            ;;
        *)
            echo "[!] Command '${1}' is not defined."
            exit 1
            ;;
    esac
fi
