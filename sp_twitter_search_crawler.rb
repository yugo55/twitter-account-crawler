require 'chrome_remote'
require 'csv'
require 'timeout'
require 'json'

@chrome = ChromeRemote.client
@chrome.send_cmd('Network.enable')


def move_to_search_account(search_word)
  js = "window.location = 'https://twitter.com/search?q=#{search_word}&src=typed_query&f=user'"
  sleep 1
  @chrome.send_cmd "Runtime.evaluate", expression: js
end

def scroll_to_get_request_id(request_id_array)
  loop do
    js = "window.scrollBy({ top: document.querySelector('div[data-testid=\"cellInnerDiv\"]:last-child').getBoundingClientRect().top, behavior: 'smooth' })"
    sleep 1
    @chrome.send_cmd "Runtime.evaluate", expression: js
    response_body = @chrome.send_cmd("Network.getResponseBody", requestId: request_id_array.last)["body"]
    break if response_body == "Rate limit exceeded\n"
  end
  request_id_array.pop
end


def first_parser(request_id_array)
  user_data_array = []
  response_body = @chrome.send_cmd("Network.getResponseBody", requestId: request_id_array[0])["body"]
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
    user_data_array << [user_name, "@" + user_id, follow_count, follower_count, img_url, account_url, user_description]
  end
  user_data_array
end

def parser(request_id)
  user_data_array = []
  response_body = @chrome.send_cmd("Network.getResponseBody", requestId: request_id)["body"]
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
    user_data_array << [user_name, "@" + user_id, follow_count, follower_count, img_url, account_url, user_description]
  end
  user_data_array
end

request_id = nil
request_id_array = []
@chrome.on('Network.responseReceived') do |res|
  if res["response"]["url"].include?("SearchTimeline")
    request_id = res["requestId"]
    request_id_array << request_id
  end
end

search_word = ARGV[0]
move_to_search_account(search_word)
scroll_to_get_request_id(request_id_array)

CSV.open("sp_twitter_search_crawler.csv", "w", force_quotes: true) do |csv|
  time = Time.now
  csv << ["検索ワード", "クロール日時", "ユーザー名", "ユーザーID", "フォロー数", "フォロワー数", "画像URL", "アカウントURL", "ユーザー説明文"]
  first_parser(request_id_array).each do |user_data|
    csv << [search_word, time, user_data].flatten
  end
  request_id_array.drop(1).each do |request_id|
    parser(request_id).each do |user_data|
      csv << [search_word, time, user_data].flatten
    end
  end
end
