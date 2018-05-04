#!/bin/bash

echo -e "\e[7m FETCHING DATA \e[5m... \e[0m"

cd ${FOE_DECRYPTION_PATH}
git fetch --quiet --all
git reset --quiet --hard origin/Docker
curl -s -L -o Main.swf "https://foeen.innogamescdn.com/swf/Main.swf?time=$(date +%s)"
python src/decryption.py

cd ${FFDEC_PATH}
./ffdec.sh \
	-selectclass de.innogames.shared.networking.providers.JSONConnectionProvider,de.innogames.strategycity.Version \
	-export script ${FFDEC_PATH}/output ${FOE_DECRYPTION_PATH}/Main.decrypted.swf \
	2>&1 >/dev/null

for i in VERSION VERSION_SECRET BUILD_TIME BUILD_NUMBER
do
	work=$( \
		cat ${FFDEC_PATH}/output/scripts/de/innogames/strategycity/Version.as | \
		grep "${i}:String" | \
		sed 's/^[^"]*"//g' | \
		sed 's/".*$//g' \
	)
	eval "$i=\"$work\""
done

SECRET=$( \
	cat ${FFDEC_PATH}/output/scripts/de/innogames/shared/networking/providers/JSONConnectionProvider.as | \
	grep "hash(" | \
	sed 's/^[^"]*"//g' | \
	sed 's/".*$//g' \
)

echo -e "\
Found:\n \
	- VERSION        = \e[32m ${VERSION} \e[0m\n \
	- VERSION_SECRET = \e[32m ${VERSION_SECRET} \e[0m\n \
	- BUILD_TIME     = \e[32m ${BUILD_TIME} \e[0m\n \
	- BUILD_NUMBER   = \e[32m ${BUILD_NUMBER} \e[0m\n \
	- SECRET         = \e[32m ${SECRET} \e[0m \
"
