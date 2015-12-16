#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# For some reason, the deploy stage shell has tracing turned on.  Lets turn it off
set +x
##########
# Colors - Lets have some fun ##
##########
Green='\e[0;32m'
Red='\e[0;31m'
Yellow='\e[0;33m'
Cyan='\e[0;36m'
no_color='\e[0m' # No Color
beer='\xF0\x9f\x8d\xba'
delivery='\xF0\x9F\x9A\x9A'
beers='\xF0\x9F\x8D\xBB'
eyes='\xF0\x9F\x91\x80'
cloud='\xE2\x98\x81'
litter='\xF0\x9F\x9A\xAE'
fail='\xE2\x9B\x94'
harpoons='\xE2\x87\x8C'
tools='\xE2\x9A\x92'
present='\xF0\x9F\x8E\x81'
#############
# http://serverfault.com/questions/7503/how-to-determine-if-a-bash-variable-is-empty#answer-382740
if [ -z $(cf s|grep drupaldb|cut -d" " -f1-1) ]; then
  echo -e "${fail}${Red}  Compose PostGresql Service [${Yellow}drupaldb${Red}] was not found${no_color}"
  return 1
fi

echo -e "${tools}${Yellow}  Sendgrid detection routine ...${no_color}" > /dev/null 2>&1
if [ -n $(cf s|grep sendgrid|cut -d" " -f1-1) ] && [ $(cf s|grep sendgrid|cut -d" " -f1-1) != "sendmail" ]; then
  echo -e "${eyes}${Yellow}   Detected existing sendgrid service ${existingSendgrid} within target space${no_color}"
  echo -e "${tools}${Yellow}    Updating manifest.yml file to match target space sendgrid service${no_color}"
  sed -e "s/sendmail/$(cf s|grep sendgrid|cut -d" " -f1-1)/g" ./manifest.yml > manifest.new
  rm manifest.yml
  mv manifest.new manifest.yml
else
  echo -e "${fail}${Red}    Sendgrid Service ${Yellow}sendmail${Red} was not available${no_color}"
fi

p=0
until [ $p -ge 2 ]
do
   cf push "${CF_APP}" -n "iw-${CF_APP}-${CF_SPACE}" && echo -e "${beer} ${beers}${Green}  Congrats! Your secure Drupal deploy is up and running!${no_color}" && echo -e "${beer} ${beers}${Green}  finis coronat opus${no_color}" && break
   p=$[$p+1]
   sleep 10
done
# view logs
#cf logs "${CF_APP}" --recent
