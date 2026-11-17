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

-- Ensure SQLite foreign key constraints are enforced
PRAGMA foreign_keys = ON;

-- Set output format for readability during evaluation
.headers on
.mode column


-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS (Statements 1 to 10)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 01: Restaurants in Los Angeles
-- Explanation: Retrieve the name, street and phone number of every restaurant
--              located in Los Angeles, sorted alphabetically by name.
-- ----------------------------------------------------------------------------
SELECT name, street, phone
FROM Restaurant
WHERE city = 'Los Angeles'
ORDER BY name;

-- ----------------------------------------------------------------------------
-- Statement 02: Videos with Hashtag Captions
-- Explanation: Find the videos whose caption contains a hashtag, using pattern
--              matching, listed from the most recently posted.
-- ----------------------------------------------------------------------------
SELECT video_id, caption, posted_at
FROM Video
WHERE caption LIKE '%#%'
ORDER BY posted_at DESC;

-- ----------------------------------------------------------------------------
-- Statement 03: Distinct Cities Covered
-- Explanation: List each city that has at least one stored restaurant, without
--              duplicates, to show the areas the map currently covers.
-- ----------------------------------------------------------------------------
SELECT DISTINCT city
FROM Restaurant
ORDER BY city;

-- ----------------------------------------------------------------------------
-- Statement 04: Extraction Confidence Summary
-- Explanation: Compute the total number of restaurant mentions and the average,
--              lowest and highest confidence of the extraction step.
-- ----------------------------------------------------------------------------
SELECT
    COUNT(*)                  AS total_mentions,
    ROUND(AVG(confidence), 3) AS average_confidence,
    MIN(confidence)           AS lowest_confidence,
    MAX(confidence)           AS highest_confidence
FROM Mentions;

-- ----------------------------------------------------------------------------
-- Statement 05: Restaurants That Could Not Be Geocoded
-- Explanation: Find the restaurants with no latitude or longitude; these appear
--              in the table view but cannot be pinned on the map.
-- ----------------------------------------------------------------------------
SELECT restaurant_id, name, city
FROM Restaurant
WHERE latitude IS NULL OR longitude IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 06: Insert a New Cuisine
-- Explanation: Add Peruvian to the list of cuisines so restaurants can be
--              tagged with it. OR IGNORE keeps cuisine names stored only once.
-- ----------------------------------------------------------------------------
INSERT OR IGNORE INTO Cuisine (name)
VALUES ('Peruvian');

-- ----------------------------------------------------------------------------
-- Statement 07: Register a New User
-- Explanation: Create an account for a new user with a salted password hash;
--              the user_id and created_at values are filled in automatically.
-- ----------------------------------------------------------------------------
INSERT OR IGNORE INTO User (username, email, password_hash)
VALUES ('foodiefay', 'fay@example.com', 'pbkdf2$5a1c$b07d93e6f2');

-- ----------------------------------------------------------------------------
-- Statement 08: Add a Missing Phone Number
-- Explanation: Update Smash Bros Burgers (restaurant 5), which was stored
--              without a phone number, with its contact number.
-- ----------------------------------------------------------------------------
UPDATE Restaurant
SET phone = '323-555-0105'
WHERE restaurant_id = 5;

-- ----------------------------------------------------------------------------
-- Statement 09: Fill In Missing Creator Display Names
-- Explanation: For every creator with no display name, use their handle
--              without the leading @ so the creator filter never shows a blank.
-- ----------------------------------------------------------------------------
UPDATE Creator
SET display_name = SUBSTR(handle, 2)
WHERE display_name IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 10: Delete Low-Confidence Mentions
-- Explanation: Remove restaurant mentions whose extraction confidence is below
--              0.60, since they are too unreliable to show to users.
-- ----------------------------------------------------------------------------
DELETE FROM Mentions
WHERE confidence < 0.60;


-- ============================================================================
-- SECTION 2: INTERMEDIATE STATEMENTS (Statements 11 to 21)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 11: Videos with Their Creator and Submitter
-- Explanation: Join each video to the creator who posted it and the user who
--              submitted it, listed from the most recent submission.
-- ----------------------------------------------------------------------------
SELECT
    V.video_id,
    C.handle       AS creator,
    U.username     AS submitted_by,
    V.submitted_at
FROM Video V
JOIN Creator C ON V.creator_id = C.creator_id
JOIN User U    ON V.submitted_by = U.user_id
ORDER BY V.submitted_at DESC;

-- ----------------------------------------------------------------------------
-- Statement 12: Restaurants Recommended by Each Creator
-- Explanation: Follow the chain creator, video, transcript, mention, restaurant
--              to list which restaurants each creator talked about and where.
-- ----------------------------------------------------------------------------
SELECT
    C.handle   AS creator,
    R.name     AS restaurant,
    R.city,
    M.confidence
FROM Creator C
JOIN Video V      ON V.creator_id = C.creator_id
JOIN Transcript T ON T.video_id = V.video_id
JOIN Mentions M   ON M.transcript_id = T.transcript_id
JOIN Restaurant R ON R.restaurant_id = M.restaurant_id
ORDER BY C.handle, R.name;

-- ----------------------------------------------------------------------------
-- Statement 13: Number of Restaurants per Cuisine
-- Explanation: Count how many restaurants serve each cuisine by joining the
--              Serves relationship to Cuisine and grouping by cuisine.
-- ----------------------------------------------------------------------------
SELECT
    Cu.name                AS cuisine,
    COUNT(S.restaurant_id) AS restaurant_count
FROM Cuisine Cu
JOIN Serves S ON S.cuisine_id = Cu.cuisine_id
GROUP BY Cu.cuisine_id, Cu.name
ORDER BY restaurant_count DESC, Cu.name;

-- ----------------------------------------------------------------------------
-- Statement 14: Most Saved Restaurants (GROUP BY & HAVING)
-- Explanation: Find the restaurants that at least 3 different users have saved,
--              with the number of saves and the date of the latest save.
-- ----------------------------------------------------------------------------
SELECT
    R.restaurant_id,
    R.name,
    COUNT(SR.user_id) AS times_saved,
    MAX(SR.saved_at)  AS last_saved_at
FROM Restaurant R
JOIN SavedRestaurant SR ON SR.restaurant_id = R.restaurant_id
GROUP BY R.restaurant_id, R.name
HAVING COUNT(SR.user_id) >= 3
ORDER BY times_saved DESC;

-- ----------------------------------------------------------------------------
-- Statement 15: Videos Still Waiting for a Transcript (LEFT OUTER JOIN)
-- Explanation: Left join videos to transcripts and keep the rows with no match
--              to find submitted videos that have not been transcribed yet.
-- ----------------------------------------------------------------------------
SELECT
    V.video_id,
    V.tiktok_url,
    V.submitted_at
FROM Video V
LEFT JOIN Transcript T ON T.video_id = V.video_id
WHERE T.transcript_id IS NULL;

-- ----------------------------------------------------------------------------
-- Statement 16: Saved-List Size per User (LEFT JOIN & GROUP BY)
-- Explanation: Count how many restaurants each user has saved, keeping users
--              with an empty list by using a left join so they show a 0.
-- ----------------------------------------------------------------------------
SELECT
    U.user_id,
    U.username,
    COUNT(SR.restaurant_id) AS saved_restaurants
FROM User U
LEFT JOIN SavedRestaurant SR ON SR.user_id = U.user_id
GROUP BY U.user_id, U.username
ORDER BY saved_restaurants DESC, U.username;
