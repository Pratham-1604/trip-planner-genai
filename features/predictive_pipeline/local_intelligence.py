import re

def extract_local_tips(comments):
    """
    Extract insider tips or hidden gems from a list of Reddit comments.
    Handles both raw text strings and dicts with a 'text' key.
    """
    tips = []
    for comment in comments:
        # If it's a dict, extract the "text" field
        if isinstance(comment, dict):
            text = comment.get("text", "")
        else:
            text = str(comment)

        sentences = re.split(r'[.!?]', text)
        for s in sentences:
            if any(k in s.lower() for k in ["hidden", "tip", "gem", "avoid", "must", "try"]):
                tips.append(s.strip())

    return tips
