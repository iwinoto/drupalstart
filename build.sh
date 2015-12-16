#!/bin/bash
# © Copyright IBM Corporation 2015.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Derived from dW article @ https://developer.ibm.com/bluemix/2014/02/17/deploy-drupal-application-ibm-bluemix/
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
echo ""
echo -e "${cloud}${Cyan}  Let's setup Drupal for initial deployment${no_color}"
#echo -e "${tools}${Yellow}    Updating apt-get ...${no_color}"
#sudo apt-get update > /dev/null 2>&1
# Install jq
echo -e "${tools}${Yellow}    Installing jq for JSON parsing support...${no_color}"
sudo apt-get --assume-yes install jq > /dev/null 2>&1
echo -e "${tools}${Yellow}    Installing zip/unzip...${no_color}"
sudo apt-get --assume-yes install zip unzip > /dev/null 2>&1

# Let's pull the open source code for Twilio-php SDK
echo -e "${harpoons}${Yellow}    Updating git submodules ...${no_color}"
git submodule update --init --recursive > /dev/null 2>&1

echo -e "${harpoons}${Yellow}    Fetching Drupal Zip ...${no_color}"
mkdir htdocs
wget http://ftp.drupal.org/files/projects/drupal-7.41.zip -nv -O ./bluezone/drupal.zip
echo -e "${tools}${Yellow}    Extracting Drupal${no_color}"
unzip -o ./bluezone/drupal.zip -d ./htdocs > /dev/null 2>&1

echo -e "${tools}${Cyan}    Setting up default site folders ...${no_color}"
mv ./bluezone/configtweaks/files ./htdocs/drupal-7.41/sites/default

echo -e "${tools}${Yellow}    Setting up best practice modules  ...${no_color}"
echo -e "${tools}${Cyan}      Installing Security Review Module ...${no_color}"
wget http://ftp.drupal.org/files/projects/security_review-7.x-1.2.zip -nv -O ./bluezone/securityreview.zip
unzip -o ./bluezone/securityreview.zip -d ./htdocs/drupal-7.41/sites/all/modules > /dev/null 2>&1

echo -e "${tools}${Cyan}      Installing 403 Redirect Module ...${no_color}"
wget http://ftp.drupal.org/files/projects/r4032login-7.x-1.8.zip -nv -O ./bluezone/r4032login.zip
unzip -o ./bluezone/r4032login.zip -d ./htdocs/drupal-7.41/sites/all/modules > /dev/null 2>&1

echo -e "${tools}${Cyan}    Setting up user provided modules ...${no_color}"
for f in ./bluezone/configtweaks/libraries/*; do
    if [ -d ${f} ]; then
        # Will not run if no directories are available
        echo -e "${harpoons}${Cyan}      Installing ${f} User-Provided Module ...${no_color}"
        mv $f ./htdocs/drupal-7.41/sites/all/libraries
    else
        echo -e "${fail}${Cyan}      No User-Provided Modules detected...${no_color}"
    fi
done

for f in ./bluezone/configtweaks/modules/*; do
    if [ -d ${f} ]; then
        # Will not run if no directories are available
        echo -e "${harpoons}${Cyan}      Installing ${f} User-Provided Module ...${no_color}"
        mv $f ./htdocs/drupal-7.41/sites/all/modules
    else
        echo -e "${fail}${Cyan}      No User-Provided Modules detected...${no_color}"
    fi
done

for f in ./bluezone/configtweaks/themes/*; do
    if [ -d ${f} ]; then
        # Will not run if no directories are available
        echo -e "${harpoons}${Cyan}      Installing ${f} User-Provided Module ...${no_color}"
        mv $f ./htdocs/drupal-7.41/sites/all/themes
    else
        echo -e "${fail}${Cyan}      No User-Provided Modules detected...${no_color}"
    fi
done

# Organize the artifact structure to be CF PHP Buildpack friendly
echo -e "${cloud}${Yellow}    Making artifacts CF PHP friendly ...${no_color}"
mv ./bluezone/configtweaks/.bp-config .
mkdir .extensions
mv ./bluezone/configtweaks/.php-extensions .

# Organize the artifact structure to facilitate BMX deploy
echo -e "${cloud}${Yellow}    Making drupal artifacts ${Cyan}Bluemix ${Yellow}friendly ...${no_color}"
mv ./bluezone/configtweaks/.user.ini ./htdocs/drupal-7.41

echo -e "${cloud}${Yellow}    Hardening drupal .htaccess ...${no_color}"
echo -e "" >> ./htdocs/drupal-7.41/.htaccess
echo -e "# Forces a redirect to SSL" >> ./htdocs/drupal-7.41/.htaccess
echo -e "RewriteCond %{HTTP:X-Forwarded-Proto} !https" >> ./htdocs/drupal-7.41/.htaccess
echo -e "RewriteRule .* https://%{SERVER_NAME}%{REQUEST_URI} [R,L]" >> ./htdocs/drupal-7.41/.htaccess

# mv ./bluezone/configtweaks/.htaccess ./htdocs/drupal-7.41
#
# Embed config file if provided
if [ -f "./bluezone/configtweaks/settings.php" ]; then
   echo -e "${tools}${Cyan}    Drupal Config file detected ...${no_color}"
   mv ./bluezone/configtweaks/settings.php ./htdocs/drupal-7.41/sites/default
else
   echo -e "${tools}${Cyan}    NO Drupal Config file detected, using default ...${no_color}"
   cp ./htdocs/drupal-7.41/sites/default/default.settings.php ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "\$application = getenv(\"VCAP_APPLICATION\");" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "\$application_json = json_decode(\$application,true);" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "if (isset(\$application_json[\"application_uris\"])) {" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "  \$base_url = \"https://\" . \$application_json[\"application_uris\"][0];" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "}" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "\$services = getenv(\"VCAP_SERVICES\");" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "\$services_json = json_decode(\$services,true);" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "if (isset(\$services_json)) {" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "  if (isset(\$services_json[\"user-provided\"][0][\"credentials\"])) {" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "    \$postgres_config = \$services_json[\"user-provided\"][0][\"credentials\"];" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "    list(\$hostname, \$port) = explode(':', \$postgres_config[\"public_hostname\"]);" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "    \$dbname = 'compose';" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "  }" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "}" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "\$databases = array (" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "  'default' =>" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "  array (" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "    'default' =>" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "    array (" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "      'driver' => 'pgsql'," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "      'database' => \$dbname," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "      'username' => \$postgres_config[\"username\"]," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "      'password' => \$postgres_config[\"password\"]," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "      'host' => \$hostname," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "      'port' => \$port," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "      'prefix' => 'main_'" >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "    )," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e "  )," >> ./htdocs/drupal-7.41/sites/default/settings.php
   echo -e ");" >> ./htdocs/drupal-7.41/sites/default/settings.php
fi

# Cleaning up
echo -e "${litter}${Yellow}    Cleaning up repository...${no_color}"
rm -rf ./bluezone
rm -rf .bluemix

# Generate Config Fetcher Script
IFS='|' read -ra PROJECT_NAME <<< "$IDS_PROJECT_NAME"
echo -e "${tools}${Yellow}    Generating config helper download script...${no_color}"
echo -e "#!/bin/bash" > fetchConfig.sh
echo -e "rm ./bluezone/configtweaks/settings.php" >> fetchConfig.sh
echo -e "cf files${PROJECT_NAME[1]} /app/htdocs/drupal-7.41/sites/default/settings.php > ./bluezone/configtweaks/settings.php" >> fetchConfig.sh
echo -e "sed -i -e '1,3d' ./bluezone/configtweaks/settings.php" >> fetchConfig.sh
chmod +x fetchConfig.sh
echo -e "${present} ${beers}${Green}  Way to go! Your Drupal Assembly present is ready!"