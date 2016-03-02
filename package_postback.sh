#!/usr/bin/env bash

HOST="POSTBACK_HOST"
IMAGE_ID=$(curl -X GET -H 'Accept: text/plain' http://$HOST/api/image_id/$1)

if [ -e "/usr/bin/dpkg" ]
then
	dpkg-query -W -f='${Package} ${Version}\.${Architecture}\n' > /tmp/tmp/packages.txt
	curl -X POST -H 'Accept: application/json' -H "Content-Type: application/json" -d "$(cat /tmp/tmp/packages.txt)" http://$HOST/api/pkg_info/$1/$IMAGE_ID/dpkg
fi

if [ -e "/usr/bin/rpm" ]
then
	rpm -qa --queryformat='%{NAME} %{VERSION}-%{RELEASE}\n' | sort -n > /tmp/packages.txt
	curl -X POST -H 'Accept: application/json' -H "Content-Type: application/json" -d "$(cat /tmp/packages.txt)" http://$HOST/api/pkg_info/$1/$IMAGE_ID/rpm
fi

if [ -e "/bin/rpm" ]
then
	rpm -qa --queryformat='%{NAME} %{VERSION}-%{RELEASE}\n' | sort -n > /tmp/packages.txt
	curl -X POST -H 'Accept: application/json' -H "Content-Type: application/json" -d "$(cat /tmp/packages.txt)" http://$HOST/api/pkg_info/$1/$IMAGE_ID/rpm
fi

if [ -e "/usr/bin/pacman" ]
then
	pacman -Qe > /tmp/packages.txt
	curl -X POST -H 'Accept: application/json' -H "Content-Type: application/json" -d "$(cat /tmp/packages.txt)" http://$HOST/api/pkg_info/$1/$IMAGE_ID/pacman
fi

if [ -e "/usr/bin/equery" ]
then
	equery list "*" > /tmp/pkg_list.txt
	curl -X POST -H 'Accept: application/json' -H "Content-Type: application/json" -d "$(cat /tmp/pkg_list.txt)" http://$HOST/api/pkg_info/$1/$IMAGE_ID/portage
fi
