#!/data/data/com.termux/files/usr/bin/bash
##
##  Service file for TOR
##
##  Run 'service tor start' to start this service
##

# show service info for tor when running 'service list'
if [ "${1}" == "--info" ]; then
    echo "the onion router"
    exit 0
fi

if [ ! -f "${PREFIX}/etc/tor/torrc" ]; then
    echo "== ERROR: TOR configuration file is not exist."
    exit 1
fi

if grep -q -P '^%include\s+/data/data/com.termux/files/usr/etc/tor/addons/relay.torrc\s*' "${PREFIX}/etc/tor/torrc"; then
    ENABLE_RELAYING=true
else
    ENABLE_RELAYING=false
fi

if ${ENABLE_RELAYING}; then
    RELAY_CONFIG="${PREFIX}/etc/tor/addons/relay.torrc"

    ## ORPort is required for relaying
    TOR_ORPORT=$(grep -P '^\s*ORPort\s+\d+\s*$' "${RELAY_CONFIG}" | awk '{ print $2 }')

    ## DirPort is optional
    TOR_DIRPORT=$(grep -P '^\s*DirPort\s+\d+\s*$' "${RELAY_CONFIG}" | awk '{ print $2 }')

    if [ -z "${TOR_ORPORT}" ]; then
        echo "== ERROR: relaying enabled, but ORPort is not set."
        exit 1
    fi

    # obtain device IP (needed for port forwarding)
    DEVICE_IP=$(ifconfig wlan0 | grep -P '\binet\b' | awk '{ print $2 }')
    if [ -z "${DEVICE_IP}" ]; then
        echo "== Device is not connected to Wi-Fi."
        echo "   Relaying disabled."
        ENABLE_RELAYING=false
    fi
fi

###############################################################################
##
##  Service functions
##
###############################################################################

start_service()
{
    local CURRENT_PID
    CURRENT_PID=$(pgrep -u "${TERMUX_UID}" -f '^tor$')

    if ! grep -q -P '^\s*RunAsDaemon\s+1\s*$' "${PREFIX}/etc/tor/torrc"; then
        echo "== ERROR: tor is not configured to run as daemon."
        exit 1
    fi

    if [ ! -z "${CURRENT_PID}" ]; then
        echo "== TOR is already running."
        exit 1
    else
        echo -n "== Starting TOR... "
        if tor > /dev/null 2>&1; then
            echo "OK"

            if ${ENABLE_RELAYING}; then
                echo -n "== Forwarding ORPort via UPnP... "
                if upnpc -e "TOR Relay" -a "${DEVICE_IP}" "${TOR_ORPORT}" "${TOR_ORPORT}" tcp >/dev/null 2>&1; then
                    echo "OK"
                else
                    echo "FAIL"
                    exit 1
                fi

                if [ ! -z "${TOR_DIRPORT}" ]; then
                    echo -n "== Forwarding DirPort via UPnP... "
                    if upnpc -e "TOR Directory Mirror" -a "${DEVICE_IP}" "${TOR_DIRPORT}" "${TOR_DIRPORT}" tcp >/dev/null 2>&1; then
                        echo "OK"
                    else
                        echo "FAIL"
                        exit 1
                    fi
                fi
            fi
        else
            echo "FAIL"
            exit 1
        fi
    fi
}

stop_service()
{
    local CURRENT_PID

    CURRENT_PID=$(pgrep -u "${TERMUX_UID}" -f '^tor$')

    if [ ! -z "${CURRENT_PID}" ]; then
        if ${ENABLE_RELAYING}; then
            echo -n "== Removing ORPort forwarding... "
            if upnpc -d "${TOR_ORPORT}" tcp > /dev/null 2>&1; then
                echo "OK"
            else
                echo "FAIL"
            fi

            if [ ! -z "${TOR_DIRPORT}" ]; then
                echo -n "== Removing DirPort forwarding... "
                if upnpc -d "${TOR_DIRPORT}" tcp > /dev/null 2>&1; then
                    echo "OK"
                else
                    echo "FAIL"
                fi
            fi
        fi

        echo -n "== Stopping TOR... "
        if killall -u $(id -un "${TERMUX_UID}") -q -w -TERM $(ps -p "${CURRENT_PID}" -o comm=) > /dev/null 2>&1; then
            echo "OK"
            exit 0
        else
            echo "FAIL"
            exit 1
        fi
    else
        echo "== TOR is not running."
        exit 1
    fi
}

service_status()
{
    local CURRENT_PID

    CURRENT_PID=$(pgrep -u "${TERMUX_UID}" -f '^tor$')

    if [ ! -z "${CURRENT_PID}" ]; then
        echo "== TOR is running, pid ${CURRENT_PID}."

        if ${ENABLE_RELAYING}; then
            echo -n "== Is ORPort forwarded: "
            if [ -z "$(upnpc -l 2>&1 | grep ${DEVICE_IP}:${TOR_ORPORT})" ]; then
                echo "no"
            else
                echo "yes"
            fi

            if [ ! -z "${TOR_DIRPORT}" ]; then
                echo -n "== Is DirPort forwarded: "
                if [ -z "$(upnpc -l 2>&1 | grep ${DEVICE_IP}:${TOR_DIRPORT})" ]; then
                    echo "no"
                else
                    echo "yes"
                fi
            fi
        fi
    else
        echo "== TOR is not running."
    fi

    exit 0
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
