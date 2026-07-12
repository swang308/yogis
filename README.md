# Yogis

Marketing + booking site for the Yogis yoga studio. Built with [Astro](https://astro.build), deployed on Cloudflare Pages.

Live: https://yogis-site.pages.dev

## Develop

```bash
npm install
npm run dev        # local dev server at http://localhost:4321
```

## Build

```bash
npm run build      # outputs static site to ./dist
npm run preview    # preview the production build locally
```

## Deploy

Deploys happen automatically: every push to `master` triggers a Cloudflare Pages build.

- **Framework preset:** Astro
- **Build command:** `npm run build`
- **Build output directory:** `dist`

To roll back, use the Deployments tab in the Cloudflare Pages dashboard.

## Structure

```
src/
  layouts/Base.astro     # shared nav + footer, brand styles
  pages/
    index.astro          # landing page
    schedule.astro       # weekly schedule + teacher/location/level filters
    courses.astro        # online courses
    studios.astro        # studio locations
    blog.astro           # blog index
    new-to-yogis.astro   # intro guide + FAQ
    login.astro          # member login (UI only until backend is wired)
  styles/global.css      # brand palette + shared components
```

Class and course data currently live as arrays at the top of each page. These
will move to Supabase (see `supabase/` once set up) so content can be edited
without code changes and to power login, booking, and course purchases.

## Brand colors

| Token | Hex | Use |
|---|---|---|
| `--cream` | `#F0EAE0` | page background |
| `--blue` | `#B9D0D6` | section backgrounds, cards |
| `--lavender` | `#B6A7CD` | accents |
| `--purple` | `#978FC4` | highlights |
| `--purple-dark` | `#6B5FA8` | buttons, links, text on light bg |
