# Status Update

Generate a casual status update for Slack by checking git history and recently merged PRs.

## Usage
- Default: Look back 1 day from today
- Pass a timeframe argument to look back further (e.g., "week", "3 days", "2 weeks")

## Steps

1. Get the current date using the `date` command
2. Calculate the lookback date based on the timeframe (default: 1 day)
3. Check git log for commits by the current user within the timeframe
4. Use `gh pr list --state merged` to find recently merged PRs by the current user
5. Use `gh pr list --state open --author @me` and `gh pr list --state closed --author @me` to find PRs submitted within the timeframe (check the `createdAt` date)
6. Create a casual summary suitable for posting in Slack
7. Sort items in chronological order (oldest first, newest last)

## PR Categories

When reporting on PRs, distinguish between:
- **Merged PRs**: PRs that were merged within the timeframe
- **Submitted PRs**: PRs that were opened/created within the timeframe (may still be open or under review)

## Output Format

Write a casual status update for Slack with two sections:

**Since last update**
- Fixed that annoying bug with user auth
- Added dark mode to the settings page
- Got the new search feature working

**In progress**
- Notification system overhaul (PR in review)
- Database migration for user preferences (draft PR up)

### Guidelines
- **Since last update**: Merged PRs and completed work within the timeframe, sorted chronologically (oldest first)
- **In progress**: Open PRs submitted within the timeframe - include brief status like "PR in review", "draft PR up", "awaiting feedback"
- Keep it conversational, focus on what got done, no PR numbers or technical jargon
- Use plain dashes (-) for list items to ensure easy copy/paste into Slack
- Omit a section entirely if there's nothing to report for it