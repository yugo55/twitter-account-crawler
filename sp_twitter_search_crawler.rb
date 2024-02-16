require 'chrome_remote'
require 'nokogiri'
require 'csv'

def wait_for_complete
  loop do
    sleep 1
    response = @chrome.send_cmd "Runtime.evaluate", expression: "document.readyState;"
    break if response["result"]["value"] == "complete"
  end
end

@chrome = ChromeRemote.client
search_text = gets.chomp
js = "window.location = 'https://twitter.com/search?q=#{search_text}&src=typed_query&f=user'"
sleep 1
@chrome.send_cmd "Runtime.evaluate", expression: js
wait_for_complete

html = @chrome.send_cmd "Runtime.evaluate", expression: "document.documentElement.outerHTML"
doc = Nokogiri.parse(html["result"]["value"])

CSV.open("sp_twitter_search_crawler.csv", "w") do |csv|
  doc.css("div[data-testid='cellInnerDiv']").each do |div|
    puts div.css("")
  end
end
