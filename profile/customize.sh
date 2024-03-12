#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>
##
## Archcraft ARM Post Installation Customisations
##
## Customize the following variables according to your need.

## ---------------------------------------------------------

# Set Hostname
your_hostname='archcraft'

# Set System Locale
# A list of supported locales is included in '/etc/locale.gen' file
# Example: your_locale='en_US.UTF-8'
your_locale='C.UTF-8'

# Set Timezone
# To list available zones, Run : timedatectl list-timezones
# Or, Look for a zoneinfo file under '/usr/share/zoneinfo'
# Example: your_timezone='Asia/Kolkata'
your_timezone='UTC'

# Set Clock
# There are two time standards: 'localtime' and 'utc'
your_clock='utc'

# Add New User
your_username='archcraft'
your_password='archcraft'
your_groups='wheel,storage,power,network,video,audio,lp,sys,optical,scanner,rfkill'
your_shell='/bin/zsh'
