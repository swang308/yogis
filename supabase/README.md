# Supabase setup

The backend that will power member login, class booking, and course purchases.
Nothing here is wired into the site yet — these are the setup steps and the
schema, ready to go once a project exists.

## 1. Create a project

1. Sign up at https://supabase.com (free tier).
2. Create a new project. Pick a region close to your studios.
3. Save the database password somewhere safe.

## 2. Load the schema

Open the project's **SQL Editor**, paste the contents of [`schema.sql`](./schema.sql),
and run it. This creates the tables (studios, teachers, classes, sessions,
members, bookings, courses, lessons, purchases), a `session_availability` view,
and row-level-security policies.

## 3. Copy your keys

Go to **Project Settings → API** and copy:

- Project URL  → `PUBLIC_SUPABASE_URL`
- `anon` public key → `PUBLIC_SUPABASE_ANON_KEY`

Put them in a local `.env` (copy `.env.example`). In Cloudflare Pages, add the
same two variables under **Settings → Environment variables** so production
builds can read them.

## 4. Seed some data (optional)

Add a couple of studios, teachers, and classes via the Supabase **Table editor**,
or ask me to write a `seed.sql` from the data currently on the site.

## What comes next (once the project is live)

- Wire the login page to Supabase Auth (email + magic link or password).
- Read `/schedule` from `sessions` + `session_availability` instead of the
  hardcoded array, so the filters query real data.
- Make the "Book" buttons create rows in `bookings`.
- Add Stripe Checkout for class packs and course purchases; a webhook writes
  to `purchases` using the service-role key.

Note: booking and auth need JavaScript in the browser (client-side Supabase
calls) or the Cloudflare adapter for server routes. We'll pick the approach
when we start this step.
