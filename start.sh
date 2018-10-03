#!/bin/sh

# Import configurations from configuration volume
mkdir -p $CFG_VOLUME
if [ ! -f $CFG_VOLUME/named.conf ]; then
	cp /etc/bind/named.conf.authoritative $CFG_VOLUME/named.conf.bak
	find $CFG_VOLUME -name *.conf -print -exec sh -c 'include "{}"; >> $CFG_VOLUME/named.conf.bak' \;
	mv $CFG_VOLUME/named.conf.bak $CFG_VOLUME/named.conf
	sed -i 's/listen-on {.*}.*;/listen-on port 3500 { any; };/g' $CFG_VOLUME/named.conf
fi

# Start application
if [ "$1" == "default" ]; then
        echo "Starting bind server"
        exec named -c $CFG_VOLUME/named.conf -g -u named
elif [ "$1" == "addZone" ]; then
	if [ -z "$2" ] || [ -z "$3" ]; then
	        echo "You have to specify an zone name and a name server"
        	exit 1
	fi
	grep -v $2 $CFG_VOLUME/named.conf > $CFG_VOLUME/named.conf2
	rm $CFG_VOLUME/named.conf
	mv $CFG_VOLUME/named.conf2 $CFG_VOLUME/named.conf
	KEYFILE=$(./addZone.sh $2 $3 $CFG_VOLUME | tee -a $CFG_VOLUME/named.conf | grep key | sed 's/include.*"\(.*\)".*;/\1/')
	cat $KEYFILE
else
    echo "Executing command"
    exec "$@"
fi
