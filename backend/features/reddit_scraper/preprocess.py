def preprocess_reddit_data(posts):
    text_corpus = []
    for post in posts:
        text_corpus.append(post["title"])
        text_corpus.extend(post["comments"])
    return " ".join(text_corpus[:2000])  # truncate for MVP
