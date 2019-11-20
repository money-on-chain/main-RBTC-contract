NETWORK=$1
END=$2


echo Continuing
npm run migrate-$NETWORK

echo Did carry-over


for i in $(seq 1 $END); do
	if [ -f tmp/${i}_* ]; then
		echo On step ${i}
		mv tmp/${i}_* migrations
		npm run migrate-$NETWORK

	fi
done
