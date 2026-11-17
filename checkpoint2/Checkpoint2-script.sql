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
