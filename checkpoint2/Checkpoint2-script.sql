-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Script
-- Project Title: FoodFriend: Turning TikTok Recommendations into a Restaurant Map
-- Team Members: Alston Bravo, Eduardo Sanchez
-- File: Checkpoint2-script.sql
-- ============================================================================

-- ============================================================================
-- SCHEMA MODIFICATIONS SINCE CHECKPOINT 1
-- ============================================================================
-- Modifications:
-- 1. [Description of schema modification 1, or None]
-- ============================================================================

-- ============================================================================
-- MEMBER CONTRIBUTIONS SUMMARY (GROUPED AT THE TOP)
-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS
-- Statement 01: [Member 1]: XX%, [Member 2]: XX%
-- ============================================================================

PRAGMA foreign_keys = ON;

.headers on
.mode column


-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS (Statements 1 to 10)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 01: LA restaurants
-- Explanation: Gets the name, street and phone of all the restaurants in
--              Los Angeles, sorted by name.
-- ----------------------------------------------------------------------------
SELECT name, street, phone
FROM Restaurant
WHERE city = 'Los Angeles'
ORDER BY name;

-- ----------------------------------------------------------------------------
-- Statement 02: Videos with a hashtag in the caption
-- Explanation: Finds videos where the caption has a # in it, newest first.
-- ----------------------------------------------------------------------------
SELECT video_id, caption, posted_at FROM Video
WHERE caption LIKE '%#%'
ORDER BY posted_at DESC;

-- ----------------------------------------------------------------------------
-- Statement 03: Cities we have restaurants in
-- Explanation: Lists every city that shows up in Restaurant, no repeats.
-- ----------------------------------------------------------------------------
SELECT DISTINCT city FROM Restaurant
ORDER BY city;

-- ----------------------------------------------------------------------------
-- Statement 04: Confidence stats
-- Explanation: Counts all the mentions and gets the avg, min and max
--              confidence so we can see how well the extraction is doing.
-- ----------------------------------------------------------------------------
SELECT COUNT(*) AS total_mentions,
       ROUND(AVG(confidence),3) AS avg_conf,
       MIN(confidence) AS min_conf, MAX(confidence) AS max_conf
FROM Mentions;

-- ----------------------------------------------------------------------------
-- Statement 05: Restaurants with no coordinates
-- Explanation: Finds restaurants that were never geocoded. These show in
--              the table but cant go on the map.
-- ----------------------------------------------------------------------------
SELECT restaurant_id, name, city
FROM Restaurant
WHERE latitude IS NULL OR longitude IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 06: Add a cuisine
-- Explanation: Adds Peruvian to Cuisine. OR IGNORE so it doesnt get added
--              twice if the script is run again.
-- ----------------------------------------------------------------------------
INSERT OR IGNORE INTO Cuisine (name) VALUES ('Peruvian');

-- ----------------------------------------------------------------------------
-- Statement 07: Register a new user
-- Explanation: Makes a new account. user_id and created_at get filled in
--              by the defaults.
-- ----------------------------------------------------------------------------
INSERT OR IGNORE INTO User (username, email, password_hash)
VALUES ('foodiefay', 'fay@example.com', 'pbkdf2$5a1c$b07d93e6f2');

-- ----------------------------------------------------------------------------
-- Statement 08: Fix a missing phone number
-- Explanation: Smash Bros Burgers (id 5) had no phone so this sets it.
-- ----------------------------------------------------------------------------
UPDATE Restaurant SET phone = '323-555-0105'
WHERE restaurant_id = 5;

-- ----------------------------------------------------------------------------
-- Statement 09: Fill in blank display names
-- Explanation: If a creator has no display name, use their handle without
--              the @ in front.
-- ----------------------------------------------------------------------------
UPDATE Creator
SET display_name = substr(handle, 2)
WHERE display_name IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 10: Delete bad mentions
-- Explanation: Deletes mentions with confidence under 0.60 since those are
--              probably wrong.
-- ----------------------------------------------------------------------------
DELETE FROM Mentions WHERE confidence < 0.60;


-- ============================================================================
-- SECTION 2: INTERMEDIATE STATEMENTS (Statements 11 to 21)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 11: Videos with creator and who submitted it
-- Explanation: Joins Video with Creator and User to show who posted each
--              video and which user submitted the link.
-- ----------------------------------------------------------------------------
SELECT v.video_id, c.handle, u.username, v.submitted_at
FROM Video v
JOIN Creator c ON v.creator_id = c.creator_id
JOIN User u ON v.submitted_by = u.user_id
ORDER BY v.submitted_at DESC;

-- ----------------------------------------------------------------------------
-- Statement 12: What each creator recommended
-- Explanation: Goes from Creator to Video to Transcript to Mentions to
--              Restaurant to list the restaurants each creator talked about.
-- ----------------------------------------------------------------------------
SELECT c.handle, r.name, r.city, m.confidence
FROM Creator c, Video v, Transcript t, Mentions m, Restaurant r
WHERE v.creator_id = c.creator_id
  AND t.video_id = v.video_id
  AND m.transcript_id = t.transcript_id
  AND r.restaurant_id = m.restaurant_id
ORDER BY c.handle, r.name;

-- ----------------------------------------------------------------------------
-- Statement 13: Restaurants per cuisine
-- Explanation: Counts how many restaurants serve each cuisine.
-- ----------------------------------------------------------------------------
SELECT cu.name, COUNT(*) AS num_restaurants
FROM Cuisine cu
JOIN Serves s ON s.cuisine_id = cu.cuisine_id
GROUP BY cu.cuisine_id
ORDER BY num_restaurants DESC, cu.name;

-- ----------------------------------------------------------------------------
-- Statement 14: Most saved restaurants
-- Explanation: Restaurants that 3 or more users saved, with how many saves
--              and when the last one was.
-- ----------------------------------------------------------------------------
SELECT r.restaurant_id, r.name, COUNT(sr.user_id) AS times_saved, MAX(sr.saved_at) AS last_saved
FROM Restaurant r
JOIN SavedRestaurant sr ON sr.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_id
HAVING COUNT(sr.user_id) >= 3
ORDER BY times_saved DESC;

-- ----------------------------------------------------------------------------
-- Statement 15: Videos with no transcript yet
-- Explanation: Left join Video to Transcript and keep the ones with no
--              match, so we know which videos still need to be transcribed.
-- ----------------------------------------------------------------------------
SELECT v.video_id, v.tiktok_url, v.submitted_at
FROM Video v LEFT JOIN Transcript t ON t.video_id = v.video_id
WHERE t.transcript_id IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 16: How many restaurants each user saved
-- Explanation: Counts saved restaurants per user. Left join so users with
--              nothing saved still show up with 0.
-- ----------------------------------------------------------------------------
SELECT u.user_id, u.username, COUNT(sr.restaurant_id) AS num_saved
FROM User u
LEFT JOIN SavedRestaurant sr ON sr.user_id = u.user_id
GROUP BY u.user_id
ORDER BY num_saved DESC, u.username;

-- ----------------------------------------------------------------------------
-- Statement 17: Mentions above average confidence
-- Explanation: Uses a subquery for the average confidence and returns the
--              mentions that are higher than it.
-- ----------------------------------------------------------------------------
SELECT m.transcript_id, r.name, m.confidence
FROM Mentions m
JOIN Restaurant r ON r.restaurant_id = m.restaurant_id
WHERE m.confidence > (SELECT AVG(confidence) FROM Mentions)
ORDER BY m.confidence DESC;

-- ----------------------------------------------------------------------------
-- Statement 18: Follower and video counts per creator
-- Explanation: For each creator, two subqueries in the SELECT count their
--              followers and their videos.
-- ----------------------------------------------------------------------------
SELECT c.handle,
    (SELECT COUNT(*) FROM Follows f WHERE f.creator_id = c.creator_id) AS followers,
    (SELECT COUNT(*) FROM Video v WHERE v.creator_id = c.creator_id) AS videos
FROM Creator c
ORDER BY followers DESC;

-- ----------------------------------------------------------------------------
-- Statement 19: Users who follow @laeatsdaily
-- Explanation: Gets the users whose id is in the list of followers of the
--              creator @laeatsdaily.
-- ----------------------------------------------------------------------------
SELECT username, email
FROM User
WHERE user_id IN (
      SELECT f.user_id FROM Follows f
      JOIN Creator c ON c.creator_id = f.creator_id
      WHERE c.handle = '@laeatsdaily');

-- ----------------------------------------------------------------------------
-- Statement 20: Add a note to saves that arent on the map
-- Explanation: If a saved restaurant has no coordinates and the user left
--              no note, set the note to say its not on the map yet.
-- ----------------------------------------------------------------------------
UPDATE SavedRestaurant
SET note = 'not on map yet'
WHERE note IS NULL
  AND restaurant_id IN (SELECT restaurant_id FROM Restaurant WHERE latitude IS NULL);

-- ----------------------------------------------------------------------------
-- Statement 21: Restaurants nobody saved
-- Explanation: Restaurants whose id is not in SavedRestaurant at all.
-- ----------------------------------------------------------------------------
SELECT restaurant_id, name, city
FROM Restaurant
WHERE restaurant_id NOT IN (SELECT restaurant_id FROM SavedRestaurant);
