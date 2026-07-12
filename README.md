# 🧘 Yogis

A yoga studio website with a **live, database-backed class schedule** — built
with Astro, Cloudflare Pages, and Supabase, running on **$0/month** free tiers.

**Live site → https://yogis-site.pages.dev**

<!-- Add a screenshot: save one as docs/images/home.png and uncomment -->
<!-- ![Yogis homepage](docs/images/home.png) -->

## Features

- **Live schedule** — classes come from a Postgres database; edit a row in the
  Supabase dashboard and the site updates on reload, no redeploy
- **Filters** — schedule filtering by teacher, location, and level, generated
  from the data itself
- Landing page, online course catalog, studio pages, beginner's guide with FAQ,
  and blog — all static, fast, and pre-rendered
- Auto-deploy: every push to `master` builds and ships via Cloudflare Pages
- Database schema ready for the next phase: member auth, bookings with
  capacity tracking, and course purchases (row-level security throughout)

## Stack

| Layer | Tech | Cost |
|---|---|---|
| Framework | [Astro](https://astro.build) — static-first, JS only where needed | free |
| Hosting + CI | Cloudflare Pages, auto-deploy from this repo | free |
| Database | Supabase (Postgres + RLS), read from the browser | free |
| Fonts / design | Fraunces + system stack, hand-rolled CSS, no framework | free |

## Project structure

```
src/
  layouts/Base.astro       # shared nav + footer
  lib/supabase.js          # database client
  pages/                   # one file = one route
    index.astro            # landing
    schedule.astro         # live schedule (fetches from Supabase)
    courses.astro          # course catalog
    studios.astro          # locations
    blog.astro             # blog index
    new-to-yogis.astro     # beginner guide + FAQ
    login.astro            # login UI (auth coming)
  styles/global.css        # brand palette + shared components
supabase/
  schema.sql               # tables, view, RLS policies
  seed.sql                 # sample data
docs/
  OWNERS_GUIDE.md          # how to run the site day-to-day
  HOW_TO_BUILD.md          # tutorial: build a site like this from scratch
```

## Run it locally

```bash
git clone https://github.com/swang308/yogis.git && cd yogis
npm install
cp .env.example .env        # fill in your Supabase URL + publishable key
npm run dev                 # http://localhost:4321
```

**Database:** create a free [Supabase](https://supabase.com) project, run
`supabase/schema.sql` in its SQL editor, then `supabase/seed.sql` for sample
data. Keys live in Project Settings → API Keys.

## Deploy

Connect the repo to a Cloudflare Pages project (framework preset **Astro**,
build `npm run build`, output `dist`) and add two environment variables:
`PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_ANON_KEY`. Every push deploys.

## Roadmap

- [x] Static site + brand design
- [x] Git auto-deploy (Cloudflare Pages)
- [x] Live schedule from Supabase + filters
- [ ] Member login (Supabase Auth)
- [ ] Class booking with live capacity
- [ ] Stripe checkout for class packs & courses
- [ ] Gated course video (Bunny Stream)
- [ ] Custom domain

## Docs

- [Owner's Guide](docs/OWNERS_GUIDE.md) — running the site without touching code
- [How to Build](docs/HOW_TO_BUILD.md) — step-by-step recipe + the gotchas

---

*Demo content: class times, teachers, and studios are sample data.*
