#!/usr/bin/env bash

set -ex

url=localhost:8080

startDockerCompose() {
    docker-compose -f test/docker-compose.yml up -d
}

stopDockerCompose() {
    docker-compose -f test/docker-compose.yml down
}

waitForNginx() {
    done=''

    for i in {30..0}; do
        if curl -s $url &> /dev/null ; then
            done=1
            break
        fi
        echo 'Nginx start process in progress...'
        sleep 1
    done

    if [[ ! "${done}" ]]; then
        echo "Failed to start Nginx" >&2
        exit 1
    fi
}

checkNginxResponse() {
    curl -s -I "$url" | grep '302 Found'
    curl -s -I "$url/core/authorize.php" | grep '500 Service unavailable'
    curl -s -I "$url/core/install.php" | grep '200 OK'
    curl -s -I "$url/core/modules/statistics/statistics.php" | grep '500 Service unavailable'
    curl -s -I "$url/cron" | grep '200 OK'
    curl -s -I "$url/index.php" | grep '302 Found'
    curl -s -I "$url/update.php" | grep '500 Service unavailable'
    curl -s -I "$url/non-existing.php" | grep '404 Not Found'
    curl -s -I "$url/.htaccess" | grep '404 Not Found'
    curl -s -I "$url/favicon.ico" | grep '200 OK'
    curl -s -I "$url/robots.txt" | grep '200 OK'
    curl -s -I "$url/core/misc/drupal.js" | grep '200 OK'
    curl -s -I "$url/core/misc/druplicon.png" | grep '200 OK'
}

runTests() {
    startDockerCompose
    waitForNginx
    checkNginxResponse
    stopDockerCompose
}

runTests
