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
