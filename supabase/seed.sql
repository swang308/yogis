-- Yogis — seed data (matches the schedule currently shown on the site)
-- Run in the Supabase SQL editor AFTER schema.sql. Safe to re-run only on an
-- empty database; running twice will create duplicate rows.

insert into studios (name, address, hours) values
  ('Downtown',  '128 Main Street', 'Mon–Fri 6:30a–9p · Sat–Sun 8a–6p'),
  ('Riverside', '4 River Walk',    'Mon–Fri 8a–8:30p · Sat–Sun 9a–5p');

insert into teachers (name) values
  ('Marcus'), ('Priya'), ('Jules'), ('Sofia'), ('Ana'), ('Theo');

insert into classes (name, level, duration_min) values
  ('Sunrise Vinyasa',        'All levels',   60),
  ('Lunch Flow Express',     'Intermediate', 45),
  ('Slow Flow & Breathwork', 'All levels',   60),
  ('Gentle Hatha',           'Beginner',     60),
  ('Strong Flow',            'Intermediate', 60),
  ('Candlelight Yin',        'All levels',   60),
  ('Yin & Restore',          'All levels',   60),
  ('Power Vinyasa',          'Advanced',     60),
  ('Unwind: Deep Stretch',   'All levels',   60),
  ('Weekend Flow',           'All levels',   60),
  ('Beginners'' Workshop',   'Beginner',     90),
  ('Slow Sunday Flow',       'All levels',   60),
  ('Restorative Reset',      'All levels',   60);

-- Sessions for the week of Jul 13–19, 2026. Times are stored as UTC and shown
-- as-is on the site, so 07:00Z displays as 7:00 AM. capacity doubles as
-- "spots left" until real bookings exist.
insert into sessions (class_id, teacher_id, studio_id, starts_at, duration_min, capacity) values
  ((select id from classes where name='Sunrise Vinyasa'),        (select id from teachers where name='Marcus'), (select id from studios where name='Downtown'),  '2026-07-13T07:00:00Z', 60,  8),
  ((select id from classes where name='Lunch Flow Express'),      (select id from teachers where name='Jules'),  (select id from studios where name='Downtown'),  '2026-07-13T12:15:00Z', 45,  5),
  ((select id from classes where name='Slow Flow & Breathwork'),  (select id from teachers where name='Ana'),    (select id from studios where name='Riverside'), '2026-07-13T18:00:00Z', 60, 10),

  ((select id from classes where name='Gentle Hatha'),            (select id from teachers where name='Priya'),  (select id from studios where name='Riverside'), '2026-07-14T09:30:00Z', 60, 12),
  ((select id from classes where name='Strong Flow'),             (select id from teachers where name='Theo'),   (select id from studios where name='Downtown'),  '2026-07-14T18:00:00Z', 60,  4),
  ((select id from classes where name='Candlelight Yin'),         (select id from teachers where name='Sofia'),  (select id from studios where name='Riverside'), '2026-07-14T19:30:00Z', 60,  7),

  ((select id from classes where name='Sunrise Vinyasa'),         (select id from teachers where name='Marcus'), (select id from studios where name='Downtown'),  '2026-07-15T07:00:00Z', 60,  6),
  ((select id from classes where name='Lunch Flow Express'),      (select id from teachers where name='Jules'),  (select id from studios where name='Downtown'),  '2026-07-15T12:15:00Z', 45,  9),
  ((select id from classes where name='Yin & Restore'),           (select id from teachers where name='Sofia'),  (select id from studios where name='Riverside'), '2026-07-15T18:00:00Z', 60, 11),

  ((select id from classes where name='Gentle Hatha'),            (select id from teachers where name='Priya'),  (select id from studios where name='Riverside'), '2026-07-16T09:30:00Z', 60, 12),
  ((select id from classes where name='Power Vinyasa'),           (select id from teachers where name='Theo'),   (select id from studios where name='Downtown'),  '2026-07-16T18:00:00Z', 60,  3),

  ((select id from classes where name='Sunrise Vinyasa'),         (select id from teachers where name='Marcus'), (select id from studios where name='Downtown'),  '2026-07-17T07:00:00Z', 60, 10),
  ((select id from classes where name='Unwind: Deep Stretch'),    (select id from teachers where name='Sofia'),  (select id from studios where name='Riverside'), '2026-07-17T17:30:00Z', 60,  8),

  ((select id from classes where name='Weekend Flow'),            (select id from teachers where name='Marcus'), (select id from studios where name='Downtown'),  '2026-07-18T09:00:00Z', 60, 14),
  ((select id from classes where name='Beginners'' Workshop'),    (select id from teachers where name='Priya'),  (select id from studios where name='Riverside'), '2026-07-18T11:00:00Z', 90,  6),

  ((select id from classes where name='Slow Sunday Flow'),        (select id from teachers where name='Ana'),    (select id from studios where name='Riverside'), '2026-07-19T10:00:00Z', 60,  9),
  ((select id from classes where name='Restorative Reset'),       (select id from teachers where name='Sofia'),  (select id from studios where name='Downtown'),  '2026-07-19T17:00:00Z', 60, 12);
