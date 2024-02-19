require 'net/http'
require 'uri'

uri = URI.parse("https://twitter.com/i/api/2/notifications/all.json?include_profile_interstitial_type=1&include_blocking=1&include_blocked_by=1&include_followed_by=1&include_want_retweets=1&include_mute_edge=1&include_can_dm=1&include_can_media_tag=1&include_ext_is_blue_verified=1&include_ext_verified_type=1&include_ext_profile_image_shape=1&skip_status=1&cards_platform=Web-12&include_cards=1&include_ext_alt_text=true&include_ext_limited_action_results=true&include_quote_count=true&include_reply_count=1&tweet_mode=extended&include_ext_views=true&include_entities=true&include_user_entities=true&include_ext_media_color=true&include_ext_media_availability=true&include_ext_sensitive_media_warning=true&include_ext_trusted_friends_metadata=true&send_error_codes=true&simple_quoted_tweet=true&count=20&requestContext=launch&ext=mediaStats%2ChighlightedLabel%2CvoiceInfo%2CbirdwatchPivot%2CsuperFollowMetadata%2CunmentionInfo%2CeditControl")
request = Net::HTTP::Get.new(uri)
request["Authority"] = "twitter.com"
request["Accept"] = "*/*"
request["Accept-Language"] = "ja"
request["Authorization"] = "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA"
request["Cookie"] = "guest_id_marketing=v1%3A170831436678243625; guest_id_ads=v1%3A170831436678243625; guest_id=v1%3A170831436678243625; gt=1759424092426629502; _ga=GA1.2.1826557525.1708314368; _gid=GA1.2.784944045.1708314368; _twitter_sess=BAh7CSIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNo%250ASGFzaHsABjoKQHVzZWR7ADoPY3JlYXRlZF9hdGwrCNGZeL%252BNAToMY3NyZl9p%250AZCIlMzE2NTkzMmMyMzhmMjIxOWI4OGRjOGQ3NjQ3NDVjYTk6B2lkIiVmYzRh%250ANDc4YTE1YjEzNmFjMzc5ZGQ5MzQ4NjIzZWU0YQ%253D%253D--b14243e5d4780bca7197dac8b189ae07ec696db9; external_referer=padhuUp37zjgzgv1mFWxJ12Ozwit7owX|0|8e8t2xd8A2w%3D; kdt=tpm1V6wkOcMto9bpxy2iPH0lk4fuKOckWEKWVP1N; auth_token=7a1767568588bc79dd8b005d93166dba3d09d7b3; ct0=a2953bb619c5ce6de1e03fbd14c00c0a2ed1cbb2eac2ec42f7810fd99181b9b315d5a13f340cda79cdc6461d16cc0fcfbbd6156f715cd426f05847cf34498b7b479dda247c749315629f56d1ad9f33d1; lang=ja; twid=u%3D1758067797262016513; att=1-MSieh4aRab52QK1Afjrky2KsDmTJ7hQXxgrMqLM9; personalization_id=\"v1_4N3g/uaP0QjrQutjHZbTbQ==\""
request["Referer"] = "https://twitter.com/home?lang=ja"
request["Sec-Ch-Ua"] = "\"Not A(Brand\";v=\"99\", \"Google Chrome\";v=\"121\", \"Chromium\";v=\"121\""
request["Sec-Ch-Ua-Mobile"] = "?0"
request["Sec-Ch-Ua-Platform"] = "\"macOS\""
request["Sec-Fetch-Dest"] = "empty"
request["Sec-Fetch-Mode"] = "cors"
request["Sec-Fetch-Site"] = "same-origin"
request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36"
request["X-Client-Transaction-Id"] = "UsrJnCbpFFERTe+Q1qU9kBiCJwJtym0OZFgF6pr1FSWRnSThthxm/nX9IiVx8NXPU00u0VPkL14VExCMYyQqPENKJ2nHUw"
request["X-Client-Uuid"] = "86c5d938-5d79-4e48-bef9-9d52627e6851"
request["X-Csrf-Token"] = "a2953bb619c5ce6de1e03fbd14c00c0a2ed1cbb2eac2ec42f7810fd99181b9b315d5a13f340cda79cdc6461d16cc0fcfbbd6156f715cd426f05847cf34498b7b479dda247c749315629f56d1ad9f33d1"
request["X-Twitter-Active-User"] = "yes"
request["X-Twitter-Auth-Type"] = "OAuth2Session"
request["X-Twitter-Client-Language"] = "ja"
request["X-Twitter-Polling"] = "true"

req_options = {
  use_ssl: uri.scheme == "https",
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

# response.code
pp response.body

File.open("cookie.json", "w") do |file|
  file.write(response.body)
end
