## 実行
ruby sp_twitter_search_crawler.rb 検索ワード

## 結果
検索ワード, クロール日時, ユーザー名, ユーザーID, フォロー数, フォロワー数, 画像URL, アカウントURL, ユーザー説明文
以上のカラムにそれぞれの情報が入る。
chrome_remoteによる自動操縦でJSONからアカウント情報を取得、CSVファイルに出力。
