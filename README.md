# Laundry Machine Booking

A one-page booking calendar for housemates. Pick a day, pick a time slot, done.
Hosted free on GitHub Pages, bookings stored free in Supabase.

## Features
- Month calendar (current + next month) with free/booked/yours at a glance
- Fixed daily time slots, configurable
- Housemates enter their name once (remembered on their device) and can add an optional note to each booking
- No double bookings — enforced by the database
- Only the device that made a booking can cancel it
- Monthly limit per person (default 4 per machine)
- Auto-refreshes every 30 s; works on phones; light & dark mode

## Setup (≈10 minutes)

### 1. Create the database (free)
1. Sign up at <https://supabase.com> → **New project** (any name, region e.g. Frankfurt/Zurich).
2. Open **SQL Editor** → **New query**, paste the contents of `supabase.sql`, click **Run**.
3. Go to **Project Settings → API** (or **API Keys**) and copy:
   - **Project URL** (`https://xxxx.supabase.co`)
   - **anon / publishable key** (the public one — *never* the `service_role`/secret key)

### 2. Configure the page
Open `index.html`, edit the `CONFIG` block at the top:

```js
BUILDING_NAME: "Our Shared House",
SUPABASE_URL: "https://xxxx.supabase.co",
SUPABASE_KEY: "eyJ...  or  sb_publishable_...",
SLOTS: [ { start: "09:00", end: "13:00" }, ... ],
MAX_PER_MONTH: 4,
QUIET_DAYS: [0],          // e.g. no laundry on Sundays
```

Want separate washer/dryer bookings? Add more entries to `RESOURCES`.

### 3. Publish on GitHub Pages
1. Create a new repository (e.g. `laundry`), upload `index.html` (and optionally this README).
2. **Settings → Pages** → Source: *Deploy from a branch* → Branch `main`, folder `/ (root)` → Save.
3. After a minute it's live at `https://<your-username>.github.io/laundry/`.
4. Share the link (or print a QR code to stick on the washing machine).

## Notes
- Without Supabase settings the page runs in **demo mode** (bookings saved only in that browser) — handy for trying it out.
- The public key only allows what `supabase.sql` permits: read bookings, create bookings, cancel with the secret token.
- If a housemate clears their browser or switches phones, they can't cancel old bookings from the new device; you (admin) can delete rows in Supabase → **Table Editor → bookings**.
- Anyone with the link can book. That's normally fine for a shared house; just keep the link in your house group chat.
- Free Supabase projects pause after ~1 week of zero activity; regular use keeps it awake (you can resume it in the dashboard if it ever pauses).
