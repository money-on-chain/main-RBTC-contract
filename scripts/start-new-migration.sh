NETWORK=$1
END=$2

# Common starting point
if [ -f tmp/${i}_* ];
then
	mv tmp/* migrations
fi
mkdir -p tmp/



mv migrations/[0-9]* tmp/


echo On step 1
mv tmp/1_* migrations/ 
npm run deploy-reset-$NETWORK
for i in $(seq 1 $END); do
	if [ -f tmp/${i}_* ]; then
		echo On step ${i}
		mv tmp/${i}_* migrations
		npm run migrate-$NETWORK

	fi
done
