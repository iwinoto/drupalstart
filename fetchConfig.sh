#!/bin/bash
rm ./bluezone/configtweaks/settings.php
cf files drupalstart-iwinoto-1610 /app/htdocs/drupal-7.41/sites/default/settings.php > ./bluezone/configtweaks/settings.php
sed -i -e '1,3d' ./bluezone/configtweaks/settings.php

