# Yogis — Owner's Guide

Everything you need to run this website day-to-day. No coding required for the
most common task (updating the schedule); light coding for everything else.

## Your accounts & links

| What | Where | Used for |
|---|---|---|
| Live site | https://yogis-site.pages.dev | What visitors see |
| Code | https://github.com/swang308/yogis | Source of truth; pushing here deploys |
| Hosting | Cloudflare dashboard → Workers & Pages → **yogis-site** | Deployments, rollbacks, env vars |
| Database | Supabase dashboard → **yogis** project | Schedule data, future members/bookings |

Keep safe (never in code or email): your Supabase **database password** and the
**secret key** (`sb_secret_…`). The publishable key (`sb_publishable_…`) is public by design.

## Site structure

| Page | Path | Content lives in |
|---|---|---|
| Home | `/` | `src/pages/index.astro` (hardcoded) |
| Schedule | `/schedule` | **Supabase database** (live) |
| Courses | `/courses` | `src/pages/courses.astro` (hardcoded) |
| Studios | `/studios` | `src/pages/studios.astro` (hardcoded) |
| Blog | `/blog` | `src/pages/blog.astro` (placeholder) |
| New to Yogis | `/new-to-yogis` | `src/pages/new-to-yogis.astro` (hardcoded) |
| Login | `/login` | UI only — real accounts come with the auth milestone |

Shared pieces: `src/layouts/Base.astro` (nav + footer), `src/styles/global.css`
(brand colors, buttons, cards).

## Everyday tasks

### Update the schedule (no code, most common)

Supabase dashboard → **Table Editor** → `sessions`.

- **Add a class occurrence:** Insert row → pick `class_id`, `teacher_id`,
  `studio_id` (the linked tables show names), set `starts_at` and `capacity`.
- **Cancel one:** delete its row.
- **Change time/teacher/spots:** edit the row.

Changes appear on the site as soon as someone reloads — no deploy needed.

Notes:
- `starts_at` is stored as UTC and **displayed exactly as entered** (07:00 shows
  as 7:00 AM). Enter times as "wall clock" times in UTC.
- New teacher or class type? Add a row to `teachers` or `classes` first.
- "Spots left" = `capacity` minus booked seats (all of capacity until booking launches).

### Change text, prices, or photos (light code)

1. Edit the relevant file in `src/pages/` (they're mostly HTML).
2. ```bash
   cd ~/Desktop/project/yogis
   git add -A && git commit -m "Update studio hours" && git push
   ```
3. Cloudflare rebuilds automatically; live in ~1 minute.

Pricing appears in two places for now: the schedule page note and `new-to-yogis.astro`.

### Roll back a bad change

Cloudflare → yogis-site → **Deployments** → pick a previous good deployment →
**⋯ → Rollback**. Instant.

## How deployment works

```
edit code → git push → GitHub → Cloudflare builds (npm run build) → live
```

- Production branch: `master`. Every push = one deployment.
- Build settings and the two `PUBLIC_SUPABASE_*` env vars live in
  Cloudflare → yogis-site → Settings.
- The schedule page talks to Supabase directly from the visitor's browser;
  everything else is pre-built static HTML.

## Costs (as set up)

| Item | Cost |
|---|---|
| Cloudflare Pages hosting | $0 (free tier, unlimited bandwidth) |
| Supabase database + auth | $0 (free tier) |
| GitHub | $0 |
| **Total today** | **$0/month** |
| Later: custom domain | ~$10/year |
| Later: Stripe payments | 2.9% + 30¢ per sale, no monthly fee |
| Later: course video (Bunny Stream) | ~$5–15/month |

Free-tier fine print: Supabase pauses projects with **7 days of zero traffic**
(dashboard → Resume fixes it; real visitor traffic prevents it) and takes **no
automatic backups**. Upgrade trigger: Supabase Pro ($25/mo) when you want
backups and no pausing — sensible once real bookings exist.

## Light maintenance routine

- **Monthly (~30 min):** update dependencies — `npm outdated`, then
  `npm update && npm run build && git push`. Or enable Dependabot on GitHub.
- **Before booking launches:** set up a weekly database backup (a small GitHub
  Action running `pg_dump` — ask Claude when ready) and free uptime monitoring
  (e.g., UptimeRobot pinging the live URL).
- **Anytime:** the site is static + free tiers; there are no servers to patch.

## Troubleshooting

| Symptom | Meaning | Fix |
|---|---|---|
| Schedule: "Schedule isn't configured yet" | Build missing env vars | Check the two `PUBLIC_SUPABASE_*` vars in Cloudflare settings, retry deployment |
| Schedule: "No classes scheduled yet" | Query worked, table empty | Add rows to `sessions` (or re-run `supabase/seed.sql`) |
| Schedule: "could not load the schedule" | Query failed | Supabase project paused? RLS policy missing? Check browser console |
| Push didn't change the site | Build failed or cache | Cloudflare → Deployments → view build log; hard-refresh (⌘⇧R) |
| Site looks unstyled after an edit | Astro scoped-style gotcha | Styles for JS-injected content need `<style is:global>` (see HOW_TO_BUILD.md) |

## Roadmap (in order)

1. **Member login** — Supabase Auth on the login page.
2. **Real booking** — "Book" buttons write to the `bookings` table; spots-left counts down.
3. **Payments** — Stripe Checkout for class packs and courses.
4. **Course videos** — Bunny Stream with purchase-gated tokens.
5. **Custom domain** — buy via Cloudflare (~$10/yr), attach to the Pages project.

The database schema for all of this already exists (`supabase/schema.sql`).
