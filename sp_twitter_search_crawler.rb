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
@chrome.send_cmd "Network.enable"
js = "window.location = 'https://twitter.com/home?lang=ja'"
@chrome.send_cmd "Runtime.evaluate", expression: js
cookies = JSON.parse(File.read("cookie.json"))
# @chrome.send_cmd('Network.setCookies', cookieObject: cookies)
@chrome.send_cmd "Network.setCookies", cookies: cookies

js = "window.location = 'https://twitter.com/home?lang=ja'"
sleep 1
@chrome.send_cmd "Runtime.evaluate", expression: js

# search_text = gets.chomp
# js = "window.location = 'https://twitter.com/search?q=#{search_text}&src=typed_query&f=user'"
# sleep 1
# @chrome.send_cmd "Runtime.evaluate", expression: js
# wait_for_complete

# @chrome.send_cmd('Network.enable')

# def getResponse
#   request_id = nil
#   Timeout.timeout(30) do
#     @chrome.on('Network.responseReceived') do |res|
#       if res["response"]["url"].include?("SearchTimeline")
#         request_id = res["requestId"]
#         puts request_id
#       end
#     end
#     @chrome.listen_until { request_id }
#   end
#   puts request_id
#   @chrome.send_cmd("Network.getRequestPostData", requestId: request_id)
# end

# loop do
#   js = "window.scrollBy({ top: document.querySelector('div[data-testid=\"cellInnerDiv\"]:last-child').getBoundingClientRect().top, behavior: 'smooth' })"
#   sleep 1
#   @chrome.send_cmd "Runtime.evaluate", expression: js
#   wait_for_complete
#   # break if doc.at_css("div[data-testid='cellInnerDiv']:last-child span")&.inner_text == "問題が発生しました。再読み込みしてください。"
# end
