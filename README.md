# Telegram_RSS_Notify
Simple Bash script which send notification about news from "https://thehackernews.com" to my telegram app.

## How to setup this script ?

- Add following command to your crontab and script will check news every 3 minutes.

#RSS TELEGRAM Notification

*/3 * * * * /bin/sh /home/your_path/news_rss_feed.sh

### In case that script can't gather data you will be informed with error notification just one-time. In case that news are available again you will get notification with news.

### screenshot:
![image](https://github.com/whoamiUNIX/Telegram_RSS_Notify/blob/master/screenshots/example_notification.png)
