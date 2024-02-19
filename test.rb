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

CSV.open("sp_twitter_search_crawler.csv", "w+", force_quotes: true) do |csv|
  csv << ["ユーザー名","ユーザーID", "画像URL", "アカウントURL", "アカウント説明文"]
  loop do
    sleep 1
    html = @chrome.send_cmd "Runtime.evaluate", expression: "document.documentElement.outerHTML"
    doc = Nokogiri.parse(html["result"]["value"])
    doc.css("div[data-testid='cellInnerDiv']").each do |div|
      user_name = div.at_css("span span")&.inner_text
      user_id = div.css(".css-175oi2r .r-1awozwy .r-18u37iz .r-1wbh5a2 a").inner_text
      img_url = div.css("img")&.attribute("src")
      user_url = div.at_css("a")&.attribute("href")
      user_explain = div.css(".css-1rynq56.r-bcqeeo.r-qvutc0.r-37j5jr.r-a023e6.r-rjixqe.r-16dba41.r-1h8ys4a.r-1jeg54m").inner_text
      csv << [user_name, user_id, img_url, user_url, user_explain]
    end
    js = "window.scrollBy({ top: document.querySelector('div[data-testid=\"cellInnerDiv\"]:last-child').getBoundingClientRect().top, behavior: 'smooth' })"
    sleep 1
    @chrome.send_cmd "Runtime.evaluate", expression: js
    wait_for_complete
    break if doc.at_css("div[data-testid='cellInnerDiv']:last-child span")&.inner_text == "問題が発生しました。再読み込みしてください。"
  end
end
