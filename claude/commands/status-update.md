# Status Update

Generate a casual status update for Slack by checking git history and recently merged PRs.

## Usage
- Default: Look back 1 day from today
- Pass a timeframe argument to look back further (e.g., "week", "3 days", "2 weeks")

## Steps

1. Get the current date using the `date` command
2. Calculate the lookback date based on the timeframe (default: 1 day)
3. Check git log for commits by the current user within the timeframe
4. Use `gh pr list` to find recently merged PRs by the current user
5. Create a casual summary suitable for posting in Slack

## Output Format

Write a casual bulleted list like you're updating your team on Slack. For example:
- Fixed that annoying bug with user auth
- Added dark mode to the settings page
- Cleaned up some old code in the API
- Got the new search feature working

Keep it conversational and focus on what got done, not PR numbers or technical jargon. No fluff, just straight to the point.