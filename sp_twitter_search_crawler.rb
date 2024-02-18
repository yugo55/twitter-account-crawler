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

CSV.open("sp_twitter_search_crawler.csv", "w") do |csv|
  loop do
    sleep 1
    html = @chrome.send_cmd "Runtime.evaluate", expression: "document.documentElement.outerHTML"
    doc = Nokogiri.parse(html["result"]["value"])
    doc.css("div[data-testid='cellInnerDiv']").each do |div|
      csv << [div.at_css("span span").inner_text]
    end
    js = "window.scrollBy({ top: document.querySelector('div[data-testid=\"cellInnerDiv\"]:last-child').getBoundingClientRect().top, behavior: 'smooth' })"
    sleep 1
    @chrome.send_cmd "Runtime.evaluate", expression: js
    break if doc.at_css("div[data-testid='cellInnerDiv']:last-child span").inner_text == "問題が発生しました。再読み込みしてください。"
  end
end
