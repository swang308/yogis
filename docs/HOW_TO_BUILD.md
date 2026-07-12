# How to Build a Site Like This

A recipe for a small-business website with a live, database-backed schedule —
for **$0/month** until it grows. This is exactly how the Yogis site was built.

**The stack, and why:**

| Piece | Choice | Why |
|---|---|---|
| Framework | [Astro](https://astro.build) | Ships plain HTML/CSS; JavaScript only where needed |
| Hosting | Cloudflare Pages (free) | Unlimited bandwidth; auto-deploys from GitHub. (Vercel's free tier forbids commercial use; Netlify caps bandwidth) |
| Database + auth | Supabase (free) | Real Postgres + login + row-level security, generous free tier |
| Payments (later) | Stripe | No monthly fee, pay per transaction |
| Total | | $0/mo + ~$10/yr for a domain |

**Architecture in one sentence:** almost every page is static HTML built at
deploy time; the pages that need live data (the schedule) fetch it from
Supabase **in the visitor's browser**, so content edits in the database appear
instantly without redeploying.

## Prerequisites

Node 20+, git, and free accounts on GitHub, Cloudflare, and Supabase.

## Step 1 — Scaffold Astro

```bash
mkdir mysite && cd mysite
npm init -y && npm install astro
mkdir -p src/pages src/layouts src/styles
```

Add scripts to `package.json`: `"dev": "astro dev", "build": "astro build"`.

Create three things:
- `src/styles/global.css` — CSS variables for your brand palette, plus shared
  button/card classes. Define colors once, use everywhere.
- `src/layouts/Base.astro` — the shared shell: `<head>`, nav, footer, and a
  `<slot />` where each page's content goes.
- `src/pages/index.astro` — your homepage. Every file in `src/pages/` becomes
  a route (`about.astro` → `/about`).

Run `npm run dev` and build out your pages as static HTML first. Get the whole
site looking right with hardcoded placeholder content before touching a database.

**Design tips that made Yogis look decent fast:** pick 4–5 brand colors and
never deviate; one display font for headings (Google Fonts), system font for
body; derive a darker shade of your accent color for buttons/text so contrast
passes; reuse one `.card` and one `.btn` style everywhere.

## Step 2 — GitHub + Cloudflare Pages (auto-deploy)

```bash
git init && git add -A && git commit -m "First version"
# create an empty repo on github.com, then:
git remote add origin git@github.com:YOU/mysite.git
git push -u origin main
```

In the Cloudflare dashboard: **Workers & Pages → Create → Pages → Import an
existing Git repository** → authorize GitHub → pick the repo →
framework preset **Astro** (build `npm run build`, output `dist`) → deploy.

From now on `git push` = deploy (~1 min), with history and one-click rollback.

`.gitignore` must include: `node_modules/`, `dist/`, `.env`.

## Step 3 — Supabase (the live data)

1. Create a project (free tier). Save the DB password somewhere safe.
2. In the SQL Editor, create your tables **with Row Level Security**. Pattern:

```sql
create table sessions (
  id bigint generated always as identity primary key,
  class_id bigint references classes(id),
  starts_at timestamptz not null,
  capacity int not null default 12
);

alter table sessions enable row level security;

-- public data: anyone can read, nobody can write (writes go through you)
create policy "public read" on sessions for select using (true);
```

Public-read for catalog data (classes, schedule); `auth.uid() = user_id`
policies for personal data (bookings, profiles). RLS is the security model —
it's what makes the next step safe.

3. Seed initial rows with `insert` statements (keep them in a `seed.sql` file in the repo).

## Step 4 — Fetch it from the page

```bash
npm install @supabase/supabase-js
```

`.env` (and `.env.example` without real values):

```
PUBLIC_SUPABASE_URL=https://YOURPROJECT.supabase.co
PUBLIC_SUPABASE_ANON_KEY=sb_publishable_...
```

The `PUBLIC_` prefix tells Astro to inline them into browser code. The
*publishable* key is safe to expose — RLS decides what it can see. The
*secret* key never goes in the site.

`src/lib/supabase.js`:

```js
import { createClient } from '@supabase/supabase-js';
export const supabase = createClient(
  import.meta.env.PUBLIC_SUPABASE_URL,
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY
);
```

In the page, fetch and render in a `<script>` block (runs in the browser):

```js
import { supabase } from '../lib/supabase.js';
const { data } = await supabase
  .from('sessions')
  .select('starts_at, capacity, classes(name)')
  .order('starts_at');
// build HTML from data, insert with element.innerHTML
```

Finally, add the same two env vars in Cloudflare (Pages project → Settings →
Variables) so production builds get them, and push.

## Gotchas (each of these cost real debugging time)

- **Astro scopes page styles.** `<style>` in a `.astro` file only applies to
  elements present at build time. Anything you insert with JavaScript gets
  *no styles*. Fix: `<style is:global>` on pages that render client-side.
- **Vercel's free tier prohibits commercial use.** For a business site, use
  Cloudflare Pages.
- **Publishable vs secret keys.** Browser gets `sb_publishable_…` only.
  If the secret key ever touches client code, rotate it.
- **Timezones.** `timestamptz` is stored UTC. Decide early whether you render
  in UTC-as-entered (simple, what Yogis does) or convert to the visitor's zone.
- **Supabase free tier pauses** after 7 days without traffic, and has **no
  automatic backups** — export or `pg_dump` on a schedule once data matters.
- **Escape user/database strings** before `innerHTML` (a 5-line helper) so a
  weird class name can't inject HTML.

## Extending

The same pattern scales to the rest of a booking business, in order:
Supabase Auth for member login (email magic links are easiest) → a `bookings`
table with own-rows RLS policies and the Book button doing an `insert` →
Stripe Checkout + a webhook for payments (needs one serverless function —
Cloudflare Pages Functions, still free tier) → gated video via Bunny Stream
tokens for online courses.

## Cost recap

$0/month on free tiers. First real costs: a domain (~$10/yr when you want one),
Stripe's per-sale fee (when you're making money), video hosting ~$5–15/mo
(only if you sell videos), Supabase Pro $25/mo (only when backups matter).
