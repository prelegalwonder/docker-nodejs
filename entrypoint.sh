#!/bin/bash

env_configure ()
{ 
  IFS=$'\n'
  ENV=$1
  COMMON_VARS=`curl "http://consul:8500/v1/kv/myapp/COMMON_VARS?raw"`
  ENV_VARS=`curl "http://consul:8500/v1/kv/myapp/ENV_VARS?raw"`
  CONFIG_FILE=$LOCAL_REPO/config/$ENV.js
  #Common Settings
  for KEY in $COMMON_VARS
    do
    VAL=`curl "http://consul:8500/v1/kv/myapp/common/$KEY?raw"`
    sed -i "s/@$KEY@/$(echo $VAL | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" $CONFIG_FILE
  done
  #Env Specific Settings
  for KEY in $ENV_VARS
    do
    VAL=`curl "http://consul:8500/v1/kv/myapp/$ENV/$KEY?raw"`
    sed -i "s/@$KEY@/$(echo $VAL | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" $CONFIG_FILE
  done
} 

cd $LOCAL_REPO
echo "Pulling the latest updates and switching to: [$MY_BRANCH] .."
git pull && git checkout $MY_BRANCH   

if [ $? -eq 0 ]
 then
   npm update && gulp

   if [ ! -f /tmp/$NODE_ENV.js ]; then
    cp $LOCAL_REPO/config/$NODE_ENV.js /tmp/$NODE_ENV.js
   fi

   case "$NODE_ENV" in
   development)  echo "Configuring app for $NODE_ENV"
      cp /tmp/$NODE_ENV.js $LOCAL_REPO/config/$NODE_ENV.js
      env_configure $NODE_ENV
      ;;
   staging)  echo "Configuring app for $NODE_ENV"
      cp /tmp/$NODE_ENV.js $LOCAL_REPO/config/$NODE_ENV.js
      env_configure $NODE_ENV
      ;;
   production)  echo "Configuring app for $NODE_ENV"
      cp /tmp/$NODE_ENV.js $LOCAL_REPO/config/$NODE_ENV.js
      env_configure $NODE_ENV
      ;;
   *) echo "Invalid Environment: $NODE_ENV"
      exit
      ;;
   esac

   chown -R $MY_USER: $LOCAL_REPO
   echo "Starting app.."
   su -c 'node app.js' $MY_USER

else
 echo "Git checkout / pull failed."
 exit 1
fi

