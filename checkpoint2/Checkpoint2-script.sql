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
-- 1. No tables or columns were added, removed or renamed. The 10 relations
--    are the same as Checkpoint 1.
-- 2. Added UNIQUE on User.username, User.email, Creator.handle,
--    Video.tiktok_url, Cuisine.name and Restaurant(name, street, city) so the
--    same link or restaurant is only stored once.
-- 3. Added CHECK constraints: latitude between -90 and 90, longitude between
--    -180 and 180, Mentions.confidence between 0 and 1.
-- 4. Added ON DELETE CASCADE on Transcript.video_id and on the foreign keys
--    of Mentions, Serves, SavedRestaurant and Follows.
-- 5. Added defaults: CURRENT_TIMESTAMP for the created_at / submitted_at /
--    saved_at / followed_at columns, 'en' for Transcript.language and
--    'whisper-1' for Transcript.model.
-- 6. Added a view MapPins (Statement 29) and a trigger auto_follow_creator
--    (Statement 31).
-- ============================================================================

-- ============================================================================
-- MEMBER CONTRIBUTIONS SUMMARY (GROUPED AT THE TOP)
-- ============================================================================
-- SECTION 1: SIMPLE STATEMENTS
-- Statement 01: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 02: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 03: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 04: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 05: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 06: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 07: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 08: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 09: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 10: Alston Bravo: 50%, Eduardo Sanchez: 50%
--
-- SECTION 2: INTERMEDIATE STATEMENTS
-- Statement 11: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 12: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 13: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 14: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 15: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 16: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 17: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 18: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 19: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 20: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 21: Alston Bravo: 50%, Eduardo Sanchez: 50%
--
-- SECTION 3: COMPLEX STATEMENTS
-- Statement 22: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 23: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 24: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 25: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 26: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 27: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 28: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 29: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 30: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 31: Alston Bravo: 50%, Eduardo Sanchez: 50%
-- Statement 32: Alston Bravo: 50%, Eduardo Sanchez: 50%
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


-- ============================================================================
-- SECTION 3: COMPLEX STATEMENTS (Statements 22 to 32)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Statement 22: Creators who talked about an SF restaurant
-- Explanation: Uses EXISTS to get creators that have at least one video
--              mentioning a restaurant in San Francisco.
-- ----------------------------------------------------------------------------
Select handle, display_name from Creator c
where exists(select * from Video v, Transcript t, Mentions m, Restaurant r
    where v.creator_id=c.creator_id and t.video_id =v.video_id
    and m.transcript_id= t.transcript_id and r.restaurant_id=m.restaurant_id
    and r.city ='San Francisco');

-- ----------------------------------------------------------------------------
-- Statement 23: Cuisines no restaurant serves
-- Explanation: NOT EXISTS checks Serves for each cuisine and keeps the ones
--              with no restaurant.
-- ----------------------------------------------------------------------------
select cuisine_id,name
from Cuisine
where not exists (select 1 from Serves where Serves.cuisine_id=Cuisine.cuisine_id);

-- ----------------------------------------------------------------------------
-- Statement 24: Activity feed for user 1
-- Explanation: Combines everything user 1 saved and everyone they followed
--              into one list with UNION ALL, newest first.
-- ----------------------------------------------------------------------------
select 'saved' as action, r.name as target, s.saved_at as happened_at
from SavedRestaurant s, Restaurant r
where s.restaurant_id=r.restaurant_id and s.user_id= 1
UNION ALL
select 'followed', c.handle, f.followed_at from Follows f,Creator c
where f.creator_id =c.creator_id and f.user_id=1
order by happened_at desc;

-- ----------------------------------------------------------------------------
-- Statement 25: Restaurants both @laeatsdaily and @cheapeatsca mentioned
-- Explanation: Gets the restaurants from creator 1's videos and intersects
--              with the ones from creator 5's videos.
-- ----------------------------------------------------------------------------
select r.restaurant_id, r.name from Restaurant r, Mentions m, Transcript t, Video v
where r.restaurant_id=m.restaurant_id and m.transcript_id=t.transcript_id
  and t.video_id=v.video_id and v.creator_id = 1
intersect
select r.restaurant_id, r.name from Restaurant r,Mentions m,Transcript t,Video v
where r.restaurant_id=m.restaurant_id and m.transcript_id=t.transcript_id
  and t.video_id=v.video_id and v.creator_id =5;

-- ----------------------------------------------------------------------------
-- Statement 26: Restaurants alston saved that eduardo didnt
-- Explanation: Takes user 1's saved restaurants and removes the ones user 2
--              also saved using EXCEPT.
-- ----------------------------------------------------------------------------
select r.name from SavedRestaurant s join Restaurant r on r.restaurant_id=s.restaurant_id
where s.user_id=1
EXCEPT
select r.name from SavedRestaurant s join Restaurant r on r.restaurant_id=s.restaurant_id
where s.user_id = 2;

-- ----------------------------------------------------------------------------
-- Statement 27: Restaurants mentioned in more than one video
-- Explanation: A CTE counts mentions and average confidence per restaurant,
--              then we join it to Restaurant and keep the ones with 2 or more.
-- ----------------------------------------------------------------------------
with counts as (
  select restaurant_id, count(*) as num_mentions, avg(confidence) as avg_conf
  from Mentions group by restaurant_id
)
select r.name, r.city, num_mentions, round(avg_conf,2) as avg_conf
from counts, Restaurant r
where r.restaurant_id=counts.restaurant_id and num_mentions>1
order by num_mentions desc, r.name;

-- ----------------------------------------------------------------------------
-- Statement 28: Rank restaurants in each city by saves
-- Explanation: Counts saves per restaurant and uses DENSE_RANK partitioned
--              by city so each city has its own ranking.
-- ----------------------------------------------------------------------------
select r.city, r.name, count(s.user_id) as saves,
   dense_rank() over(partition by r.city order by count(s.user_id) desc) as city_rank
from Restaurant r left join SavedRestaurant s on s.restaurant_id=r.restaurant_id
group by r.restaurant_id
order by r.city,city_rank;

-- ----------------------------------------------------------------------------
-- Statement 29: View for the map pins
-- Explanation: Creates a view with only the restaurants that have
--              coordinates, plus their cuisines and how many times they were
--              mentioned. This is what the map page reads from.
-- ----------------------------------------------------------------------------
drop view if exists MapPins;

create view MapPins as
select r.restaurant_id, r.name, r.city, r.latitude, r.longitude,
  (select group_concat(c.name,', ') from Serves s, Cuisine c
     where s.cuisine_id=c.cuisine_id and s.restaurant_id =r.restaurant_id) as cuisines,
  (select count(*) from Mentions m where m.restaurant_id= r.restaurant_id) as times_mentioned
from Restaurant r
where r.latitude is not null and r.longitude is not null;

-- ----------------------------------------------------------------------------
-- Statement 30: LA pins from the view
-- Explanation: Queries the MapPins view for the Los Angeles restaurants,
--              most mentioned first.
-- ----------------------------------------------------------------------------
Select name, cuisines, times_mentioned, latitude, longitude
from MapPins where city ='Los Angeles'
order by times_mentioned desc, name;

-- ----------------------------------------------------------------------------
-- Statement 31: Trigger to auto follow the creator
-- Explanation: After a user submits a video, this trigger makes them follow
--              the creator of that video if they dont already.
-- ----------------------------------------------------------------------------
drop trigger if exists auto_follow_creator;

create trigger auto_follow_creator
after insert on Video
for each row
begin
    insert or ignore into Follows(user_id, creator_id, followed_at)
    values(NEW.submitted_by, NEW.creator_id, NEW.submitted_at);
end;

-- ----------------------------------------------------------------------------
-- Statement 32: Confidence breakdown per creator
-- Explanation: Uses CASE to count how many of each creator's mentions are
--              high (0.9+), medium, or low (under 0.75) confidence.
-- ----------------------------------------------------------------------------
select c.handle,
  count(case when m.confidence>=0.9 then 1 end) as high,
  count(case when m.confidence <0.9 and m.confidence>= 0.75 then 1 end) as medium,
  count(case when m.confidence<0.75 then 1 end) as low,
  count(m.restaurant_id) as total
from Creator c
left join Video v on v.creator_id=c.creator_id
left join Transcript t on t.video_id =v.video_id
left join Mentions m on m.transcript_id=t.transcript_id
group by c.creator_id;
