require 'chrome_remote'
require 'nokogiri'
require 'csv'
require 'timeout'

def wait_for_complete
  loop do
    sleep 1
    response = @chrome.send_cmd "Runtime.evaluate", expression: "document.readyState;"
    break if response["result"]["value"] == "complete"
  end
end

@chrome = ChromeRemote.client


@chrome.send_cmd('Network.enable')

request_id = nil
Timeout.timeout(30) do
  @chrome.on('Network.responseReceived') do |res|
    if res["response"]["url"].include?("SearchTimeline")
      request_id = res["requestId"]
    end
    @chrome.listen_until { request_id }
  end
end

search_text = gets.chomp
js = "window.location = 'https://twitter.com/search?q=#{search_text}&src=typed_query&f=user'"
sleep 1
@chrome.send_cmd "Runtime.evaluate", expression: js
wait_for_complete

time = Time.now

CSV.open("sp_twitter_search_crawler.csv", "w") do |csv|
  csv << ["検索ワード", "クロール日時", "ユーザー名", "ユーザーID", "画像URL", "アカウントURL", "アカウント説明文"]
  loop do
    js = "window.scrollBy({ top: document.querySelector('div[data-testid=\"cellInnerDiv\"]:last-child').getBoundingClientRect().top, behavior: 'smooth' })"
    sleep 1
    @chrome.send_cmd "Runtime.evaluate", expression: js
    wait_for_complete
    response_body = @chrome.send_cmd("Network.getResponseBody", requestId: request_id)
    pp response_body
  end
end
