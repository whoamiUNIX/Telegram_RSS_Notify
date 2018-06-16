#!/bin/bash
## - Telegram bot send news to my telegram.
### - RSS FEED from the https://thehackernews.com

RSS_ERROR_FILE="/home/yourpath/error.txt"
RSS_ERROR=$(cat $RSS_ERROR_FILE)
RSS_ERROR_CAPACITY=$(du $RSS_ERROR_FILE | awk '{ print $1 }')
SUCCESS_LOG="/home/yourpath/news_rss_feed.log"
DUPLICATE_LOG="/home/yourpath/log/news_rss_feed_duplicate.log"
CURL_RSS=$(curl -s http://feeds.feedburner.com/TheHackersNews)
RSS_PREVENT_DUPLICATE="/home/yourpath/tmp_news_duplicate.txt"
RSS_PREVENT_COUNT_LINES=$(cat $RSS_PREVENT_DUPLICATE | wc -l)
RSS_TMP_XML="/home/yourpath/tmp_rss.xml"
RSS_CHECK=$(cat $RSS_TMP_XML | grep "<item>")
TIMESTAMP_FILE="/home/yourpath/news_rss_feed_timestamp.txt"
LAST_MESSAGE_TIMESTAMP=$(cat $TIMESTAMP_FILE)
CURRENT_TIMESTAMP=$(date +s )
CHAT_ID="your_telegram_CHATID"
TOKEN="your_bot_token"

echo $CURL_RSS > $RSS_TMP_XML

if [ ! -z "$RSS_CHECK" ]; then
	CAPACITY_VALUE="0"
	if [ $RSS_ERROR_CAPACITY != $CAPACITY_VALUE ]; then 
	truncate -s 0 $RSS_ERROR_FILE
	fi
fi

if [ -z "$RSS_CHECK" ]; then
	ERR_VALUE="error"
	if [ "$RSS_ERROR" = "$ERR_VALUE" ]; then
        #Notification was send before. Nothing to do
		exit
	else
	echo $ERR_VALUE > $RSS_ERROR_FILE
	TELEGRAM_ERROR_MESS="RSS error occured. News are affected and will not be delivered. More messages regarding this issue will not be send."
	curl -s -X POST https://api.telegram.org/YOURBOTHERE:$TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$TELEGRAM_ERROR_MESS"
	exit
	fi
fi


XML_PARSE() {
	local IFS='>'
	read -d '<' TAG VALUE
}

cat $RSS_TMP_XML | while XML_PARSE ; do
	case $TAG in
	'item')
		link=''
		pubDate=''
		;;
	'link')
		link="$VALUE"
		;;
	'pubDate')
		pubDate="$VALUE"
		;;
	'/item')
		#Convert pubDate to Unix timestamp and also check if last message was send.
		DATE_RSS=$(date -d "$pubDate" +"%s")
		if [ "$DATE_RSS" -gt "$LAST_MESSAGE_TIMESTAMP" ]; then
			echo $DATE_RSS > $TIMESTAMP_FILE
                        if (( $RSS_PREVENT_COUNT_LINES >= 30 )); then
				sed -i 1,10d $RSS_PREVENT_DUPLICATE
			fi
			GREP_DUPLICATE_MATCH=$(grep $link $RSS_PREVENT_DUPLICATE)
			if [ $? -eq 0 ]; then
				echo "DUPLICATE FOUND -- DATE:$DATE_RSS -- LINK:$link" >> $DUPLICATE_LOG
			else
				curl -s -X POST https://api.telegram.org/YOURBOTHERE:$TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$link" >> $SUCCESS_LOG
                        	printf "\n" >> $SUCCESS_LOG
				echo $link >> $RSS_PREVENT_DUPLICATE
			fi
		fi
		;;
	esac
done
exit
