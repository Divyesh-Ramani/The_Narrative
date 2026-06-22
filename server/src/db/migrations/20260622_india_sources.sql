SELECT setval(
  pg_get_serial_sequence('sources', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM sources), 0), 1),
  true
);

INSERT INTO sources (name, feed_url, base_url, category, is_active, priority, country_focus, main_genre_hint, editorial_type)
VALUES
  (
    'The Hindu - National',
    'https://www.thehindu.com/news/national/feeder/default.rss',
    'https://www.thehindu.com',
    'India',
    true,
    3,
    'india',
    'india',
    'newspaper'
  ),
  (
    'Indian Express - India',
    'https://indianexpress.com/section/india/feed/',
    'https://indianexpress.com',
    'India',
    true,
    3,
    'india',
    'india',
    'newspaper'
  ),
  (
    'Hindustan Times - India',
    'https://www.hindustantimes.com/feeds/rss/india-news/rssfeed.xml',
    'https://www.hindustantimes.com',
    'India',
    true,
    2,
    'india',
    'india',
    'newspaper'
  ),
  (
    'Times of India - Top Stories',
    'https://timesofindia.indiatimes.com/rssfeedstopstories.cms',
    'https://timesofindia.indiatimes.com',
    'India',
    true,
    2,
    'india',
    'india',
    'newspaper'
  ),
  (
    'Mint - News',
    'https://www.livemint.com/rss/news',
    'https://www.livemint.com',
    'Business',
    true,
    2,
    'india',
    'india',
    'business'
  )
ON CONFLICT (feed_url) DO UPDATE SET
  is_active = true,
  priority = EXCLUDED.priority,
  country_focus = EXCLUDED.country_focus,
  main_genre_hint = EXCLUDED.main_genre_hint,
  editorial_type = EXCLUDED.editorial_type;
