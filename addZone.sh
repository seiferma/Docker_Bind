#!/bin/sh

ZONENAME=$1
KEYNAME=management.$ZONENAME
NAMESERVER=$2
DEST=$3

# Generate key
tsig-keygen $KEYNAME > $DEST/$ZONENAME.zone.key

# Generate zone configuration
echo "zone \"$ZONENAME\" IN {
  type master;
  allow-transfer {none;};
  file \"$DEST/$ZONENAME.zone.db\";
  update-policy { grant $KEYNAME zonesub any; };
};" > $DEST/$ZONENAME.zone.conf

# Generate zone db
echo "\$ORIGIN .
\$TTL 300

$ZONENAME       IN      SOA $NAMESERVER.      whois.$NAMESERVER. (
                        $(TZ=UTC date +%Y%m%d%H)	; serial number YYMMDDNN
                        28800           ; Refresh
                        7200            ; Retry
                        864000          ; Expire
                        300             ; Min TTL
			)

                NS      $NAMESERVER." > $DEST/$ZONENAME.zone.db

# Return include directives
echo "include \"$DEST/$ZONENAME.zone.key\";"
echo "include \"$DEST/$ZONENAME.zone.conf\";"
