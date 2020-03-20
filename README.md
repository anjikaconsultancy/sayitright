# SayitRight

Notes for running and contributing to SayitRight.

## Push Code
    git add -A
    git commit -m "message"
    git push origin master 
    git push production master
    git push staging master

## Get Config
    heroku config -s --app sirn-production >> .env
    TODO - we should be able to put this in c9 env now!
## Run Code
    heroku local
    foreman start
    
## Run Code in session
    tmux new -s app
    foreman start
    
    tmux attach -t app #to re-attach to app in a new teminal window
    
## Access Site From Single Domain
    http://SITE_NAME.location/
    
## Bower
    bower install

 

## Running in docker container
    - point *.sayitright.dev at your docker ip (e.g. with gasmask or etc)
    - make sure /tmp/pids/server.pid does not exist or it will not start

    docker-compose build
    docker-compose up -d

  

