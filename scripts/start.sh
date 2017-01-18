#!/bin/sh
set -e

su eprints -c /usr/share/eprints3/scripts/epadmin_create_db
su eprints -c /usr/share/eprints3/scripts/epadmin_create_user

su eprints -c "/opt/eprints3/bin/generate_static test --verbose"
su eprints -c "/opt/eprints3/bin/import_subjects test --verbose --force"

/usr/sbin/apache2ctl -D FOREGROUND
