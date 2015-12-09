#!/bin/bash
# Set the production route to the new app version
cf map-route "${CF_APP}-new" e1.net -n "${CF_APP}"

# Rename current app version to old
cf rename "${CF_APP}-current" "${CF_APP}-old"

# Rename new app version to current
cf rename "${CF_APP}-new" "${CF_APP}-current"

# Remove production routes from the old app version
cf unmap-route "${CF_APP}-old" e1.net -n "${CF_APP}"
cf unmap-route "${CF_APP}-old" $0 -n "iw-${CF_APP}-${CF_SPACE}"
