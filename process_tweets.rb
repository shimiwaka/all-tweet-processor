#!/usr/bin/env ruby

require 'json'

def get_yes_no_answer(question)
  print "#{question} (y/n): "
  answer = gets.chomp.downcase
  answer == 'y'
end

def get_number_input
  loop do
    print "Please input number: "
    input = gets.chomp
    if input.match?(/^\d+$/)
      return input.to_i
    end
  end
end

def read_tweets
  file_path = File.join(File.dirname(__FILE__), 'tweets.js')
  json_data = File.read(file_path)
  JSON.parse(json_data)
end

def is_retweet?(tweet_data)
  # リツイートの判定方法1: retweeted_statusの存在を確認
  return true if tweet_data['retweeted_status']
  
  # リツイートの判定方法2: テキストが "RT @username:" で始まるか確認
  return true if tweet_data['full_text']&.start_with?('RT @')
  
  false
end

def generate_html(tweets_to_process)
  html_content = <<~HTML
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>Tweet Processing Results</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .tweet { border: 1px solid #ccc; padding: 15px; margin-bottom: 15px; border-radius: 5px; }
        .tweet-text { margin-bottom: 10px; }
        .tweet-images { display: flex; flex-wrap: wrap; gap: 10px; }
        .tweet-images img { max-width: 300px; border-radius: 5px; }
        .tweet-stats { color: #666; font-size: 0.9em; }
      </style>
    </head>
    <body>
      <h1>Tweet Processing Results</h1>
  HTML

  tweets_to_process.each do |tweet|
    tweet_data = tweet['tweet']
    tweet_id = tweet_data['id_str']
    full_text = tweet_data['full_text']
    favorite_count = tweet_data['favorite_count'].to_i
    has_images = tweet_data['entities']['media']&.any? { |media| media['type'] == 'photo' } || false
    is_retweet = is_retweet?(tweet_data)

    html_content += <<~HTML
      <div class="tweet">
        <div class="tweet-text">#{full_text}</div>
        <div class="tweet-stats">Favorites: #{favorite_count}</div>
    HTML

    if has_images
      html_content += '<div class="tweet-images">'
      tweet_data['entities']['media'].each do |media|
        if media['type'] == 'photo'
          html_content += "<img src=\"#{media['media_url_https']}\" alt=\"Tweet image\">"
        end
      end
      html_content += '</div>'
    end

    html_content += '</div>'
  end

  html_content += <<~HTML
    </body>
    </html>
  HTML

  output_file = File.join(File.dirname(__FILE__), 'target_tweets.html')
  File.write(output_file, html_content)
  puts "Results have been saved to #{output_file}"
end

def delete_tweets(tweets_to_process)
  delete_script = File.join(File.dirname(__FILE__), 'delete_tweet.rb')
  
  tweets_to_process.each do |tweet|
    tweet_id = tweet['tweet']['id_str']
    puts "Deleting tweet: #{tweet_id}"
    output = `ruby #{delete_script} #{tweet_id}`
    puts output
    sleep(0.3) # API制限を考慮して0.3秒待機
  end
  
  puts "All tweets have been processed for deletion."
end

process_all = get_yes_no_answer("Process all tweets?")

if !process_all
  process_only_images = get_yes_no_answer("Process only image tweets?")
  process_by_likes = get_yes_no_answer("Process only tweets fewer likes than specified number?")
  
  like_threshold = nil
  if process_by_likes
    like_threshold = get_number_input
  end
end

tweets = read_tweets
tweets_to_process = []

tweets.each do |tweet|
  tweet_data = tweet['tweet']
  tweet_id = tweet_data['id_str']
  favorite_count = tweet_data['favorite_count'].to_i
  has_images = tweet_data['entities']['media']&.any? { |media| media['type'] == 'photo' } || false
  is_retweet = is_retweet?(tweet_data)

  if is_retweet
    next
  end

  if process_only_images && !has_images
    next
  end

  if process_by_likes && favorite_count >= like_threshold
    next
  end

  tweets_to_process << tweet
end

generate_html(tweets_to_process) 

puts "Please check the target_tweets.html file."

final_confirmation = get_yes_no_answer("Do you want to delete these tweets?")

if final_confirmation
  delete_tweets(tweets_to_process)
end