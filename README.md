# The Cinephile's Ledger — Setup Guide

A shared Top 100 + four personal Top 20s. Live-syncs across all of you.

## What you're deploying

```
cinephile/
├── public/index.html     ← The app (single file)
├── api/config.js         ← Hands env vars to the browser
├── supabase-setup.sql    ← Database schema
├── vercel.json
└── package.json
```

**Three views in the app:**
- **The Canon** — shared Top 100, all four of you can edit
- **My Top 20** — your personal list (each person has their own)
- **Brother's Top 20** — view-only tabs for each other brother's list

Live sync means when one of you adds a movie, the others see it within a second.

---

# We'll do this in 3 stages. Tell me when each is done.

---

## STAGE 1 — Supabase setup

1. Go to **https://supabase.com/dashboard** and open your project (or create a new one — pick the closest region to you for lowest latency).

2. In the left sidebar click **SQL Editor → New query**.

3. Open the file `supabase-setup.sql` from this folder, **copy the entire contents**, paste into the SQL Editor, and click **Run**.

4. You should see "Success. No rows returned." That created three tables: `canon`, `personal_lists`, `curators`.

5. Now grab your project's API credentials. In the left sidebar go to **Project Settings** (gear icon) → **API**. Copy these two values somewhere safe (Notes app, etc.):
   - **Project URL** — looks like `https://abcdxyz.supabase.co`
   - **`anon` `public` API key** — a long `eyJhbGc...` string starting with eyJ

> The anon key is safe to expose to the browser. The Row-Level Security policies set up in the SQL control what it can do.

**✅ Stop here and tell me Stage 1 is done. Then I'll walk you through Stage 2.**

---

## STAGE 2 — OMDb API key (for poster auto-fetching)

1. Go to **https://www.omdbapi.com/apikey.aspx**

2. Pick the **FREE** tier (1,000 lookups/day — way more than you'll need).

3. Enter your email, click submit.

4. You'll get an activation email. **Click the activation link** (this step is easy to miss).

5. The email also contains your API key — a short string like `8d3e3b41`. Save it.

> Without this, the app still works — you'll just paste poster URLs manually.

**✅ Tell me when you have the key (or if you want to skip this).**

---

## STAGE 3 — Deploy to Vercel

### Option A: Drag-and-drop (easiest, no GitHub needed)

1. Go to **https://vercel.com/new**.

2. Look for the option to **drag and drop a folder** (under "Import" / "Other"). If you don't see it, just push to GitHub and connect that repo instead — same result.

3. Drag the entire `cinephile/` folder into the upload area.

4. Vercel will detect it as a static site with serverless functions — **don't change build settings**.

5. **Before clicking Deploy**, expand **Environment Variables** and add three:

   | Name                | Value                                    |
   |---------------------|------------------------------------------|
   | `SUPABASE_URL`      | the Project URL from Stage 1             |
   | `SUPABASE_ANON_KEY` | the anon public key from Stage 1         |
   | `OMDB_API_KEY`      | your OMDb key from Stage 2 (or blank)    |

6. Click **Deploy**.

7. After ~30 seconds, Vercel gives you a URL like `https://cinephile-ledger-xyz.vercel.app`.

8. Open that URL — first visit asks for your name. Pick what you want shown to your brothers.

9. Send your brothers the URL. Each of them types their own name on first visit.

### Option B: Vercel CLI (if you prefer the terminal)

```bash
cd cinephile
npm i -g vercel
vercel login
vercel
# When prompted: link to existing project or create new
vercel env add SUPABASE_URL production
# paste your Project URL when asked
vercel env add SUPABASE_ANON_KEY production
# paste your anon key when asked
vercel env add OMDB_API_KEY production
# paste your OMDb key when asked
vercel --prod
```

**✅ Once deployed, send me the URL or any error and I'll help debug.**

---

## How it works once live

- Each person types their name on first visit (saved in their browser).
- The Canon tab is shared — anyone can add, reorder, delete.
- The My Top 20 tab is yours alone. Other people see your tab as **read-only**.
- The four personal tabs appear in the order people first visit the site.
- Everything syncs live — you'll see changes from the others within ~1 second.

---

## Troubleshooting

**"Connection failed" on load**
→ Env vars in Vercel aren't set, or you deployed before adding them. Add them in **Vercel → Project → Settings → Environment Variables**, then **Deployments → ⋯ → Redeploy**.

**Posters aren't loading**
→ Either `OMDB_API_KEY` is blank, or OMDb didn't have that exact title. Try with the year, or paste a URL manually.

**"new row violates row-level security policy"**
→ The SQL didn't fully run. Re-run `supabase-setup.sql`.

**Realtime not updating**
→ The last block of `supabase-setup.sql` adds tables to the realtime publication. If it errored, run just that block again.

**One of my brothers can't see his Top 20 / it shows someone else's**
→ Make sure he typed the right name on first visit. He can click `[change]` next to "Curator: …" in the top right to fix it. Names are case-sensitive.

---

## Optional: lock down editing

The current setup lets anyone with the URL edit anything. If you want to enforce that only the owner can edit their personal Top 20 (so a brother can't troll your list), let me know and I'll add Supabase Auth with magic-link emails and tighten the RLS policies.
