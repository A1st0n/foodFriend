-- FoodFriend sample data (simulated) for CSE 111 Checkpoint 2
-- Build: sqlite3 Checkpoint2-dbase.sqlite3 < schema.sql
--        sqlite3 Checkpoint2-dbase.sqlite3 < seed.sql
-- All timestamps are explicit so the database is reproducible.

PRAGMA foreign_keys = ON;
BEGIN;

INSERT INTO User (user_id, username, email, password_hash, created_at) VALUES
(1, 'alston',    'alston@example.com',    'pbkdf2$a1f3$9c0e4b7d21', '2026-09-01 10:00:00'),
(2, 'eduardo',   'eduardo@example.com',   'pbkdf2$7be2$41aa90c3fe', '2026-09-01 10:05:00'),
(3, 'hungryhan', 'han@example.com',       'pbkdf2$c44d$e2b17f6a08', '2026-09-10 18:30:00'),
(4, 'tacotess',  'tess@example.org',      'pbkdf2$19e0$5d3c8a2b77', '2026-09-14 12:15:00'),
(5, 'noodlenat', 'nat@example.com',       'pbkdf2$f602$0b9e6d41c5', '2026-09-20 09:45:00'),
(6, 'sfsam',     'sam@example.net',       'pbkdf2$83ac$7f20e1d9b4', '2026-10-02 20:00:00'),
(7, 'lurker',    'lurker@example.com',    'pbkdf2$2d71$c8a45e09f3', '2026-10-15 08:20:00'),
(8, 'brunchbri', 'bri@example.org',       'pbkdf2$e5b9$364fd2a810', '2026-10-28 11:10:00');

INSERT INTO Creator (creator_id, handle, display_name) VALUES
(1, '@laeatsdaily',   'LA Eats Daily'),
(2, '@sfbites',       'SF Bites'),
(3, '@tacotuesdayla', 'Taco Tuesday LA'),
(4, '@noodlequest',   'Noodle Quest'),
(5, '@cheapeatsca',   'Cheap Eats California'),
(6, '@brunchclub',    NULL);

INSERT INTO Restaurant (restaurant_id, name, street, city, state, zip, latitude, longitude, phone) VALUES
(1,  'El Fuego Taqueria',     '1420 Sunset Blvd',     'Los Angeles',   'CA', '90026', 34.0771, -118.2587, '213-555-0101'),
(2,  'Golden Bowl Ramen',     '312 E 2nd St',         'Los Angeles',   'CA', '90012', 34.0489, -118.2396, '213-555-0102'),
(3,  'Mama Rosa Trattoria',   '8800 Melrose Ave',     'Los Angeles',   'CA', '90069', 34.0812, -118.3856, '310-555-0103'),
(4,  'Seoul Street BBQ',      '3465 W 6th St',        'Los Angeles',   'CA', '90020', 34.0637, -118.2972, '213-555-0104'),
(5,  'Smash Bros Burgers',    '5601 York Blvd',       'Los Angeles',   'CA', '90042', 34.1210, -118.1934, NULL),
(6,  'Pier 9 Oyster House',   '9 The Embarcadero',    'San Francisco', 'CA', '94111', 37.7998, -122.3977, '415-555-0106'),
(7,  'Mission Burrito Co',    '2889 Mission St',      'San Francisco', 'CA', '94110', 37.7513, -122.4184, '415-555-0107'),
(8,  'Dragon Gate Dim Sum',   '640 Jackson St',       'San Francisco', 'CA', '94133', 37.7962, -122.4064, '415-555-0108'),
(9,  'Fog City Pho',          '1901 Irving St',       'San Francisco', 'CA', '94122', 37.7636, -122.4783, NULL),
(10, 'Sunrise Brunch Cafe',   '2100 Fillmore St',     'San Francisco', 'CA', '94115', 37.7889, -122.4338, '415-555-0110'),
(11, 'Birria Brothers Truck', NULL,                   'Los Angeles',   'CA', NULL,    NULL,    NULL,      NULL),
(12, 'Noodle Alley',          '77 Alley Way',         'Oakland',       'CA', '94607', NULL,    NULL,      '510-555-0112'),
(13, 'The Vegan Joint',       '10438 National Blvd',  'Los Angeles',   'CA', '90034', 34.0283, -118.4107, '310-555-0113'),
(14, 'Valley Pizza Works',    '1560 Main St',         'Merced',        'CA', '95340', 37.3022, -120.4830, '209-555-0114'),
(15, 'Lucky Thai Kitchen',    '5185 Hollywood Blvd',  'Los Angeles',   'CA', '90027', 34.1017, -118.3009, '323-555-0115'),
(16, 'Corner Donut Shop',     '400 W Olive Ave',      'Merced',        'CA', '95348', 37.3186, -120.4800, NULL);

INSERT INTO Cuisine (cuisine_id, name) VALUES
(1, 'Mexican'), (2, 'Japanese'), (3, 'Italian'), (4, 'Korean'), (5, 'American'),
(6, 'Seafood'), (7, 'Chinese'),  (8, 'Vietnamese'), (9, 'Thai'), (10, 'Vegan'),
(11, 'Brunch'), (12, 'Ethiopian');

INSERT INTO Video (video_id, tiktok_url, caption, posted_at, submitted_at, creator_id, submitted_by) VALUES
(1,  'https://www.tiktok.com/@laeatsdaily/video/7301000000000000001',   'Top 3 tacos in Echo Park #tacos #la',          '2026-08-12 17:00:00', '2026-09-02 19:10:00', 1, 1),
(2,  'https://www.tiktok.com/@laeatsdaily/video/7301000000000000002',   'Ktown BBQ you NEED to try',                    '2026-08-25 18:30:00', '2026-09-05 12:40:00', 1, 1),
(3,  'https://www.tiktok.com/@sfbites/video/7302000000000000003',       'SF seafood crawl on the Embarcadero',          '2026-09-01 20:00:00', '2026-09-11 08:05:00', 2, 3),
(4,  'https://www.tiktok.com/@sfbites/video/7302000000000000004',       'Best burrito in the Mission? #sf',             '2026-09-09 19:15:00', '2026-09-15 21:30:00', 2, 6),
(5,  'https://www.tiktok.com/@tacotuesdayla/video/7303000000000000005', 'Birria truck with no address lol',             '2026-09-15 16:45:00', '2026-09-16 13:00:00', 3, 4),
(6,  'https://www.tiktok.com/@noodlequest/video/7304000000000000006',   'Ranking LA ramen spots',                       '2026-09-18 21:00:00', '2026-09-21 10:20:00', 4, 5),
(7,  'https://www.tiktok.com/@noodlequest/video/7304000000000000007',   'Bay Area noodle tour: pho, dim sum and more',  '2026-09-27 19:30:00', '2026-10-03 20:45:00', 4, 6),
(8,  'https://www.tiktok.com/@cheapeatsca/video/7305000000000000008',   'LA eats under $10',                            '2026-10-04 12:00:00', '2026-10-06 17:55:00', 5, 2),
(9,  'https://www.tiktok.com/@cheapeatsca/video/7305000000000000009',   'Merced hidden gems #centralvalley',            '2026-10-11 13:30:00', '2026-10-12 09:15:00', 5, 2),
(10, 'https://www.tiktok.com/@brunchclub/video/7306000000000000010',    'SF brunch that is worth the line',             '2026-10-18 10:00:00', '2026-10-29 11:30:00', 6, 8),
(11, 'https://www.tiktok.com/@laeatsdaily/video/7301000000000000011',   'Date night in WeHo: pasta edition',            '2026-10-22 19:00:00', '2026-10-30 22:10:00', 1, 3),
(12, 'https://www.tiktok.com/@tacotuesdayla/video/7303000000000000012', NULL,                                           '2026-11-01 15:00:00', '2026-11-03 14:25:00', 3, 4),
(13, 'https://www.tiktok.com/@sfbites/video/7302000000000000013',       'Late night eats in the Sunset',                '2026-11-05 23:00:00', '2026-11-08 07:50:00', 2, 1);

-- Video 13 was submitted but has not been transcribed yet (no Transcript row).
INSERT INTO Transcript (transcript_id, video_id, text, language, model, created_at) VALUES
(1,  1,  'Okay here are my top three tacos in Echo Park. Number one is El Fuego Taqueria on Sunset, get the al pastor. Then the Birria Brothers truck, and finish with a smash burger at Smash Bros Burgers on York.', 'en', 'whisper-1', '2026-09-02 19:10:48'),
(2,  2,  'If you are in Koreatown you need Seoul Street BBQ on 6th Street. The short rib is unreal. After that walk over to Golden Bowl Ramen in Little Tokyo.',                                                         'en', 'whisper-1', '2026-09-05 12:40:52'),
(3,  3,  'We are doing a seafood crawl in San Francisco. First stop Pier 9 Oyster House on the Embarcadero, then dim sum at Dragon Gate Dim Sum on Jackson Street.',                                                     'en', 'whisper-1', '2026-09-11 08:05:44'),
(4,  4,  'Everyone asks me for the best burrito in the Mission. It is Mission Burrito Co on Mission Street, no contest. Get the super carnitas.',                                                                         'en', 'whisper-1', '2026-09-15 21:30:39'),
(5,  5,  'Esta troca de birria no tiene direccion, Birria Brothers, solo siguelos en Instagram. Tambien me encanta El Fuego Taqueria en Sunset.',                                                                         'es', 'whisper-1', '2026-09-16 13:00:57'),
(6,  6,  'Ranking ramen in LA. Golden Bowl Ramen on 2nd Street is my number one, the tonkotsu is so rich. Lucky Thai Kitchen on Hollywood has a boat noodle that deserves a mention too.',                               'en', 'whisper-1', '2026-09-21 10:20:41'),
(7,  7,  'Bay Area noodle tour. Fog City Pho on Irving for the pho, Dragon Gate Dim Sum for the soup dumplings, and Noodle Alley in Oakland if you can find it.',                                                        'en', 'whisper-1', '2026-10-03 20:45:50'),
(8,  8,  'Everything here is under ten dollars. El Fuego Taqueria tacos, a single at Smash Bros Burgers, and the lunch special at The Vegan Joint on National.',                                                          'en', 'whisper-1', '2026-10-06 17:55:46'),
(9,  9,  'Merced has hidden gems. Valley Pizza Works on Main Street does a great slice.',                                                                                                                                 'en', 'gpt-4o-transcribe', '2026-10-12 09:15:35'),
(10, 10, 'This brunch is worth the line. Sunrise Brunch Cafe on Fillmore, order the lemon ricotta pancakes. If the wait is too long go to Pier 9 Oyster House for brunch oysters.',                                      'en', 'gpt-4o-transcribe', '2026-10-29 11:30:43'),
(11, 11, 'Date night in West Hollywood. Mama Rosa Trattoria on Melrose, the cacio e pepe is made tableside.',                                                                                                             'en', 'gpt-4o-transcribe', '2026-10-30 22:10:38'),
(12, 12, 'No talking in this one, just vibes and music.',                                                                                                                                                                 'en', 'gpt-4o-transcribe', '2026-11-03 14:25:31');

-- Transcript 12 mentions no restaurant; restaurant 16 is never mentioned.
INSERT INTO Mentions (transcript_id, restaurant_id, snippet, confidence) VALUES
(1,  1,  'El Fuego Taqueria on Sunset, get the al pastor',            0.97),
(1,  11, 'the Birria Brothers truck',                                 0.71),
(1,  5,  'a smash burger at Smash Bros Burgers on York',              0.93),
(2,  4,  'Seoul Street BBQ on 6th Street',                            0.96),
(2,  2,  'Golden Bowl Ramen in Little Tokyo',                         0.90),
(3,  6,  'Pier 9 Oyster House on the Embarcadero',                    0.98),
(3,  8,  'Dragon Gate Dim Sum on Jackson Street',                     0.95),
(4,  7,  'Mission Burrito Co on Mission Street',                      0.99),
(5,  11, 'Birria Brothers, solo siguelos en Instagram',               0.64),
(5,  1,  'El Fuego Taqueria en Sunset',                               0.88),
(6,  2,  'Golden Bowl Ramen on 2nd Street is my number one',          0.97),
(6,  15, 'Lucky Thai Kitchen on Hollywood has a boat noodle',         0.85),
(7,  9,  'Fog City Pho on Irving for the pho',                        0.94),
(7,  8,  'Dragon Gate Dim Sum for the soup dumplings',                0.91),
(7,  12, 'Noodle Alley in Oakland if you can find it',                0.58),
(8,  1,  'El Fuego Taqueria tacos',                                   0.89),
(8,  5,  'a single at Smash Bros Burgers',                            0.86),
(8,  13, 'the lunch special at The Vegan Joint on National',          0.92),
(9,  14, 'Valley Pizza Works on Main Street does a great slice',      0.96),
(10, 10, 'Sunrise Brunch Cafe on Fillmore',                           0.98),
(10, 6,  'go to Pier 9 Oyster House for brunch oysters',              0.87),
(11, 3,  'Mama Rosa Trattoria on Melrose',                            0.97);

-- Cuisine 12 (Ethiopian) is not served anywhere yet.
INSERT INTO Serves (restaurant_id, cuisine_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6), (6, 11), (7, 1), (8, 7),
(9, 8), (10, 11), (10, 5), (11, 1), (12, 7), (12, 8), (13, 10), (13, 5),
(14, 3), (14, 5), (15, 9), (16, 5);

-- User 7 (lurker) has saved nothing and follows nobody.
INSERT INTO SavedRestaurant (user_id, restaurant_id, saved_at, note) VALUES
(1, 1,  '2026-09-02 19:15:00', 'al pastor!!'),
(1, 4,  '2026-09-05 12:45:00', 'go with a group'),
(1, 2,  '2026-09-22 09:00:00', NULL),
(1, 9,  '2026-11-08 08:00:00', 'open late'),
(2, 1,  '2026-10-06 18:00:00', NULL),
(2, 14, '2026-10-12 09:20:00', 'close to campus'),
(2, 13, '2026-10-06 18:02:00', 'lunch special under $10'),
(3, 6,  '2026-09-11 08:10:00', 'anniversary dinner'),
(3, 3,  '2026-10-30 22:15:00', 'tableside cacio e pepe'),
(3, 1,  '2026-10-31 13:00:00', NULL),
(4, 1,  '2026-09-16 13:05:00', NULL),
(4, 11, '2026-09-16 13:06:00', 'check IG for location'),
(4, 7,  '2026-09-18 20:30:00', NULL),
(5, 2,  '2026-09-21 10:25:00', 'tonkotsu'),
(5, 9,  '2026-10-03 21:00:00', NULL),
(5, 8,  '2026-10-03 21:01:00', 'soup dumplings'),
(5, 12, '2026-10-03 21:02:00', NULL),
(6, 7,  '2026-09-15 21:35:00', 'super carnitas'),
(6, 6,  '2026-09-20 17:40:00', NULL),
(6, 8,  '2026-10-03 20:50:00', NULL),
(8, 10, '2026-10-29 11:35:00', 'lemon ricotta pancakes'),
(8, 6,  '2026-10-29 11:36:00', NULL);

INSERT INTO Follows (user_id, creator_id, followed_at) VALUES
(1, 1, '2026-09-02 19:20:00'),
(1, 4, '2026-09-22 09:05:00'),
(1, 2, '2026-11-08 08:05:00'),
(2, 5, '2026-10-06 18:05:00'),
(2, 1, '2026-10-07 10:00:00'),
(3, 2, '2026-09-11 08:15:00'),
(3, 1, '2026-10-30 22:20:00'),
(4, 3, '2026-09-16 13:10:00'),
(4, 1, '2026-09-17 09:30:00'),
(5, 4, '2026-09-21 10:30:00'),
(6, 2, '2026-09-15 21:40:00'),
(6, 4, '2026-10-03 20:55:00'),
(8, 6, '2026-10-29 11:40:00'),
(8, 2, '2026-10-29 11:41:00');

COMMIT;
