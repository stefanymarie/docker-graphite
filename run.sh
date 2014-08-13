#!/bin/bash

# Get rid of the darn carbon-cache pid to avoid restart errors
rm -f /var/lib/graphite/storage/carbon-cache-a.pid

exec /usr/bin/supervisord