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
@chrome.send_cmd('Network.enable')
@chrome.on('Network.responseReceived') do |res|
  pp res['response']['url']
end

search_text = gets.chomp
js = "window.location = 'https://twitter.com/search?q=#{search_text}&src=typed_query&f=user'"
sleep 1
@chrome.send_cmd "Runtime.evaluate", expression: js
wait_for_complete

loop do
  js = "window.scrollBy({ top: document.querySelector('div[data-testid=\"cellInnerDiv\"]:last-child').getBoundingClientRect().top, behavior: 'smooth' })"
  sleep 1
  @chrome.send_cmd "Runtime.evaluate", expression: js
  wait_for_complete
end
