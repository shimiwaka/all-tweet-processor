# all-tweet-processor
This script excecutes any operations to all tweets from tweet.js (downloaded via X archive)

## Usage

### process_tweets.rb
This script allows you to process and optionally delete tweets based on various criteria.

#### Prerequisites
- `tweet_delete_command.dat` file in the same directory
  - Please prepare yourself
  - The command in this file can be used for any operation, not just deletion, depending on its content
- `tweets.js` file containing your tweet data (downloaded via X archive)

#### How to use
1. Run the script:
   ```
   ruby process_tweets.rb
   ```

2. Follow the interactive prompts:
   - "Process all tweets? (y/n)"
   - If no, you can choose additional filters:
     - "Process only image tweets? (y/n)"
     - "Process only tweets fewer likes than specified number? (y/n)"
     - If selecting like count filter, enter the threshold number

3. Review the generated `target_tweets.html` file

4. Confirm deletion:
   - "Do you want to delete these tweets? (y/n)"

### unretweets.rb
This script allows you to process and optionally delete retweets.

#### Prerequisites
- `tweet_delete_command.dat` file in the same directory
  - The command in this file can be used for any operation, not just deletion, depending on its content
- `tweets.js` file containing your tweet data

#### How to use
1. Run the script:
   ```
   ruby unretweets.rb
   ```

2. Follow the interactive prompts:
   - "Process all retweets? (y/n)"
   - If no, you can choose additional filter:
     - "Process only retweets with fewer likes than specified number? (y/n)"
     - If selecting like count filter, enter the threshold number

3. Review the generated `target_retweets.html` file

4. Confirm deletion:
   - "Do you want to delete these retweets? (y/n)"
