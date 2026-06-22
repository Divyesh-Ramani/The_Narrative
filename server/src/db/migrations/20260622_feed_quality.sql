ALTER TABLE sources
  ADD COLUMN IF NOT EXISTS priority INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS country_focus VARCHAR(20),
  ADD COLUMN IF NOT EXISTS main_genre_hint VARCHAR(20),
  ADD COLUMN IF NOT EXISTS sub_genre_hint VARCHAR(40),
  ADD COLUMN IF NOT EXISTS editorial_type VARCHAR(30);

ALTER TABLE articles
  ADD COLUMN IF NOT EXISTS normalized_title VARCHAR(500),
  ADD COLUMN IF NOT EXISTS summary TEXT,
  ADD COLUMN IF NOT EXISTS main_genre VARCHAR(20),
  ADD COLUMN IF NOT EXISTS sub_genre VARCHAR(40),
  ADD COLUMN IF NOT EXISTS importance_score NUMERIC,
  ADD COLUMN IF NOT EXISTS is_low_signal BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS low_signal_reason VARCHAR(100),
  ADD COLUMN IF NOT EXISTS region_confidence NUMERIC,
  ADD COLUMN IF NOT EXISTS genre_confidence NUMERIC,
  ADD COLUMN IF NOT EXISTS representative_rank NUMERIC;

ALTER TABLE stories
  ADD COLUMN IF NOT EXISTS main_genre VARCHAR(20),
  ADD COLUMN IF NOT EXISTS sub_genre VARCHAR(40),
  ADD COLUMN IF NOT EXISTS importance_score NUMERIC,
  ADD COLUMN IF NOT EXISTS source_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS representative_article_id INTEGER REFERENCES articles(id),
  ADD COLUMN IF NOT EXISTS event_count INTEGER NOT NULL DEFAULT 0;

ALTER TABLE briefs
  ADD COLUMN IF NOT EXISTS article_ids INTEGER[];

ALTER TABLE timeline_entries
  ADD COLUMN IF NOT EXISTS representative_article_id INTEGER REFERENCES articles(id),
  ADD COLUMN IF NOT EXISTS event_date TIMESTAMP,
  ADD COLUMN IF NOT EXISTS importance_score NUMERIC;

CREATE INDEX IF NOT EXISTS idx_articles_normalized_title ON articles(normalized_title);
CREATE INDEX IF NOT EXISTS idx_articles_main_sub_genre ON articles(main_genre, sub_genre);
CREATE INDEX IF NOT EXISTS idx_stories_importance ON stories(importance_score DESC);

UPDATE sources
SET
  priority = CASE
    WHEN lower(name) LIKE '%reuters%' THEN 3
    WHEN lower(name) LIKE '%associated press%' OR lower(name) = 'ap' THEN 3
    WHEN lower(name) LIKE '%bloomberg%' THEN 3
    WHEN lower(name) LIKE '%financial times%' OR lower(name) LIKE '%ft%' THEN 3
    WHEN lower(name) LIKE '%bbc%' THEN 3
    WHEN lower(name) LIKE '%hindu%' THEN 3
    WHEN lower(name) LIKE '%indian express%' THEN 3
    WHEN lower(name) LIKE '%hindustan times%' THEN 2
    WHEN lower(name) LIKE '%livemint%' OR lower(name) LIKE '%mint%' THEN 2
    WHEN lower(name) LIKE '%economist%' THEN 2
    WHEN lower(name) LIKE '%techcrunch%' OR lower(name) LIKE '%verge%' OR lower(name) LIKE '%wired%' THEN 2
    WHEN lower(category) LIKE '%sports%' THEN 1
    ELSE priority
  END,
  country_focus = COALESCE(country_focus, CASE
    WHEN lower(name) LIKE '%india%' THEN 'india'
    WHEN lower(name) LIKE '%hindu%' THEN 'india'
    WHEN lower(name) LIKE '%indian express%' THEN 'india'
    WHEN lower(name) LIKE '%hindustan times%' THEN 'india'
    WHEN lower(name) LIKE '%times of india%' THEN 'india'
    WHEN lower(name) LIKE '%livemint%' OR lower(name) LIKE '%mint%' THEN 'india'
    ELSE 'global'
  END),
  main_genre_hint = COALESCE(main_genre_hint, CASE
    WHEN lower(name) LIKE '%india%' THEN 'india'
    WHEN lower(name) LIKE '%hindu%' THEN 'india'
    WHEN lower(name) LIKE '%indian express%' THEN 'india'
    WHEN lower(name) LIKE '%hindustan times%' THEN 'india'
    WHEN lower(name) LIKE '%times of india%' THEN 'india'
    ELSE 'global'
  END),
  sub_genre_hint = COALESCE(sub_genre_hint, CASE
    WHEN lower(category) LIKE '%business%' THEN 'business-finance'
    WHEN lower(category) LIKE '%market%' THEN 'markets'
    WHEN lower(category) LIKE '%tech%' THEN 'science-tech'
    WHEN lower(category) LIKE '%sport%' THEN 'sports'
    ELSE NULL
  END),
  editorial_type = COALESCE(editorial_type, CASE
    WHEN lower(name) LIKE '%reuters%' OR lower(name) LIKE '%associated press%' OR lower(name) = 'ap' THEN 'wire'
    WHEN lower(category) LIKE '%business%' THEN 'business'
    WHEN lower(category) LIKE '%tech%' THEN 'tech'
    WHEN lower(category) LIKE '%sport%' THEN 'sports'
    ELSE 'newspaper'
  END);
