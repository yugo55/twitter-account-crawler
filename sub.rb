require 'chrome_remote'
require 'csv'
require 'timeout'
require 'json'

@chrome = ChromeRemote.client
@chrome.send_cmd('Network.enable')

request_id = nil
Timeout.timeout(30) do
  @chrome.on('Network.responseReceived') do |res|
    if res["response"]["url"].include?("SearchTimeline")
      request_id = res["requestId"]
    end
  end

  js = "window.location = 'https://twitter.com/search?q=#{ARGV[0]}&src=typed_query&f=user'"
  sleep 1
  @chrome.send_cmd "Runtime.evaluate", expression: js

  @chrome.listen_until { request_id }
end

time = Time.now

def first_parser(time, request_id)
  user_data_array = []
  response_body = @chrome.send_cmd("Network.getResponseBody", requestId: request_id)["body"]
  parsed_response_body = JSON.parse(response_body)
  parsed_response_body["data"]["search_by_raw_query"]["search_timeline"]["timeline"]["instructions"][1]["entries"].each do |user|
    next unless user["content"]["itemContent"]
    user_info = user["content"]["itemContent"]["user_results"]["result"]["legacy"]
    user_name = user_info["name"]
    user_id = user_info["screen_name"]
    follow_count = user_info["friends_count"]
    follower_count = user_info["normal_followers_count"]
    img_url = user_info["profile_image_url_https"]
    account_url = "https://twitter.com/" + user_id
    user_description = user_info["description"]
    user_data_array << [ARGV[0], time, user_name, "@" + user_id, follow_count, follower_count, img_url, account_url, user_description]
  end
  user_data_array
end

def parser(time, request_id, response_body)
  user_data_array = []
  parsed_response_body = JSON.parse(response_body)
  parsed_response_body["data"]["search_by_raw_query"]["search_timeline"]["timeline"]["instructions"][0]["entries"].each do |user|
  next unless user["content"]["itemContent"]
  user_info = user["content"]["itemContent"]["user_results"]["result"]["legacy"]
  user_name = user_info["name"]
  user_id = user_info["screen_name"]
  follow_count = user_info["friends_count"]
  follower_count = user_info["normal_followers_count"]
  img_url = user_info["profile_image_url_https"]
  account_url = "https://twitter.com/" + user_id
  user_description = user_info["description"]
  user_data_array << [ARGV[0], time, user_name, "@" + user_id, follow_count, follower_count, img_url, account_url, user_description]
  end
  user_data_array
end

CSV.open("sp_twitter_search_crawler.csv", "w", force_quotes: true) do |csv|
  csv << ["検索ワード", "クロール日時",  "ユーザー名", "ユーザーID", "フォロー数", "フォロワー数", "画像URL", "アカウントURL", "アカウント説明文"]
  first_parser(time, request_id).each do |user_data|
    csv << user_data
  end
  loop do
    request_id = nil
    js = "window.scrollBy({ top: document.querySelector('div[data-testid=\"cellInnerDiv\"]:last-child').getBoundingClientRect().top, behavior: 'smooth' })"
    sleep 1
    @chrome.send_cmd "Runtime.evaluate", expression: js
    Timeout.timeout(30) do
      @chrome.listen_until { request_id }
    end
    response_body = @chrome.send_cmd("Network.getResponseBody", requestId: request_id)["body"]
    break if response_body == "Rate limit exceeded\n"
    parser(time, request_id, response_body).each do |user_data|
      csv << user_data
    end
  end
end
