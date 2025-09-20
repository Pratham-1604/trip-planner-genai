import os
import praw
from dotenv import load_dotenv

load_dotenv()

CLIENT_ID = os.getenv('REDDIT_CLIENT_ID')
CLIENT_SECRET = os.getenv('REDDIT_CLIENT_SECRET')
USER_AGENT = os.getenv('REDDIT_USER_AGENT')

reddit = praw.Reddit(
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET,
    user_agent=USER_AGENT
)

def fetch_reddit_comments(place: str, limit=50):
    results = []
    query = f"{place} travel OR trip OR recommendations"

    for submission in reddit.subreddit("all").search(query, limit=limit):
        # Collect post title + comments
        post_data = {
            "title": submission.title,
            "comments": []
        }
        submission.comments.replace_more(limit=0)  # Flatten nested comments
        for comment in submission.comments.list()[:20]:  # limit per post
            post_data["comments"].append(comment.body)
        results.append(post_data)

    return results