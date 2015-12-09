#!/bin/bash
default_domain=$1
# See if current version already exists...
if [[ `cf a` =~ .*"${CF_APP}"-current.* ]]
then
  current_exists=1
fi

# Set the production route to the new app version
cf map-route "${CF_APP}-new" e1.net -n "${CF_APP}"

if [ $current_exists -eq 1 ]
then
  # Rename current app version to old
  cf rename "${CF_APP}-current" "${CF_APP}-old"
  cf unmap-route "${CF_APP}-old" $default_domain -n "iw-${CF_APP}-current-${CF_SPACE}"
  cf map-route "${CF_APP}-current" $default_domain -n "iw-${CF_APP}-old-${CF_SPACE}"
  # Restart so that settings.php pick up the new URI and application name
  cf restart "${CF_APP}-old"
fi

# Rename new app version to current
cf rename "${CF_APP}-new" "${CF_APP}-current"
cf unmap-route "${CF_APP}-current" $default_domain -n "iw-${CF_APP}-new-${CF_SPACE}"
cf map-route "${CF_APP}-current" $default_domain -n "iw-${CF_APP}-current-${CF_SPACE}"
# Restart so that settings.php pick up the new URI and application name
cf restart "${CF_APP}-current"

if [ $current_exists -eq 1 ]
then
  # Remove production routes from the old app version
  cf unmap-route "${CF_APP}-old" e1.net -n "${CF_APP}"
fi
