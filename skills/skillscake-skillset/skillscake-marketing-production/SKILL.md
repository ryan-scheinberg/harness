---
name: skillscake-marketing-production
description: Turn approved marketing angles into channel-ready drafts, publish via Typefully (X, LinkedIn, Bluesky) and Dev.to API when configured; Medium is always manual (paste in Medium’s editor). Generates ad copy and manages the content library. Use when the user wants to draft posts, publish content, create ads, manage the content calendar, check what's been posted, or mentions "production," "drafts," "publish," "post," "schedule," "ads," or "content library." Use proactively after an ideation session produces angle files.
---

# SkillsCake Marketing Production

You run the second half of SkillsCake's marketing pipeline: turning structured angle specs into channel-ready drafts, publishing them, generating ad copy, and maintaining the content library.

You work downstream of:
1. **Angle files** produced by the ideation skill (`skillscake-marketing-ideation`), found in `skillscake-product/marketing/calendar/`
2. **Brand voice rules** from the `skillscake-marketing` skill — read it before every production run. It contains the proof table, copy rules, anti-patterns, headline principles, and voice guidelines. You do not duplicate those rules here; you enforce them.
3. **`typefully` skill** (official Typefully agent skill) — for **X, LinkedIn, and Bluesky** publishing. Read it before calling the Typefully CLI. It owns API/auth details, `drafts:*`, `queue:*`, `analytics:*`, `social-sets:*`, thread syntax, and scheduling. Install/update: `npx skills add typefully/agent-skills -y --agent cursor` (project) or `-g` for global. Skill path is usually `~/.cursor/skills/typefully` (symlink) or `skillscake/.agents/skills/typefully` when installed in-repo. **One social set** connects accounts (e.g. **@skillscake** on X, **Agent Horizon LLC** on LinkedIn); add **Bluesky** in the Typefully UI for that set if cross-posting. Use `--platform x` vs `--platform linkedin` vs `--platform bluesky`, or combine: `--platform x,bluesky` when the **same** copy ships to both (SkillsCake voice). `social-sets:list` / `social-sets:get` for IDs and URLs.

Your outputs are: drafted posts (one file per post), published content (Typefully / Dev.to API or manual where noted), ad copy variants, and content library entries.

## The product (quick reference)

- **SkillsCake:** Drag-and-drop skill optimizer. Upload a skill → get back a better one. Works for Cursor, Claude Code, ChatGPT, VS Code, GitHub Copilot, Gemini CLI, and dozens more.
- **Company:** Agent Horizon LLC (Ryan Scheinberg, solo founder)
- **Tagline:** Skills? Piece of cake.
- **Pricing:** Base $3.20/run, Pro $6.00/run (25-packs). First run free.
- **Site:** skillscake.com | Parent: agenthorizonai.com

For full proof data and claim rules, read `skillscake-marketing` — do not cite numbers without checking them against that skill's proof table.

## Production workflow

### Step 1: Read inputs

1. Read the latest angle file from `skillscake-product/marketing/calendar/`
2. Read `skillscake-marketing` (the brand/voice skill) for copy rules
3. Read [channel-specs.md](references/channel-specs.md) for format constraints
4. Scan **`library/live/`** for near-duplicates on similar angles. Deliberate repeats from the angle spec are fine
5. **Schedule:** If the angle file has `earliest_publish` and `latest_publish`, spread `scheduled_for` dates evenly across that window. Do not schedule anything before `earliest_publish` or after `latest_publish`. Ryan adjusts dates during review. Medium is always manual (founder pastes); never schedule Medium via Typefully.

### Step 2: Draft (one file per post)

For each angle in the angle file:

1. **Identify the target channels.** One angle may produce multiple drafts (e.g. an X thread + LinkedIn, or one short post duplicated to **X + Bluesky** per [channel-specs.md](references/channel-specs.md)).
2. **Write the draft** following the channel specs in [channel-specs.md](references/channel-specs.md) and the brand rules in `skillscake-marketing`.
3. **Weave in the human detail** from the angle spec. This is the specific story, number, opinion, or admission that makes the content non-generic. It should appear naturally in the post, not feel bolted on. If the angle spec says "STORY: the deploy broke at 2am" — that story should be the backbone of the post, not a parenthetical.
4. **Save each draft** to `skillscake-product/marketing/library/drafts/` as a markdown file.

#### Draft file format

Filename: `YYYY-MM-DD-channel-slug.md` (e.g. `2026-04-09-x-cursor-rules-thread.md`)

```markdown
---
date: 2026-04-09
scheduled_for: 2026-04-13
channel: x
typefully_platforms: x,bluesky
brand: skillscake
angle_ref: calendar/2026-W15-batch.md#angle-3
---

[Post content here — the exact text that gets published. Do not rewrite during scheduling.]
```

Keep frontmatter minimal: `date`, `scheduled_for`, `channel`, `brand`, `angle_ref`, and `typefully_platforms` (when cross-posting). Add `reuse_of` only for repeats/remixes. No `status`, `avatar`, or bookkeeping timestamps — the folder is the state (`drafts/` = WIP, `live/` = shipped, `killed/` = rejected).

When drafting, set **`scheduled_for`** by spreading posts evenly between `earliest_publish` and `latest_publish`. Ryan adjusts dates during review. **`scheduled_for` on disk is authoritative** — production reads it before every Typefully call, never from memory.

#### Writing rules (enforced from skillscake-marketing, repeated here because they're non-negotiable)

- **Reading level:** Third grade. Always.
- **No throat-clearing.** No "In today's rapidly evolving AI landscape..." — get to the point.
- **No weasel words.** Not "may help improve" — "improves."
- **No em dashes in shipped copy.** Use periods, commas, or colons.
- **Short paragraphs.** 1-3 sentences max.
- **Active voice.** "SkillsCake tests your skill" not "Your skill is tested by SkillsCake."
- **Specificity beats generality.** "0.14 to 0.79 in six minutes" is better than "dramatic improvement."
- **If it could apply to any AI product, rewrite.** Swap "SkillsCake" for "AnyAITool" — if it still works, it's too generic.

#### Quality gate

Before saving a draft, check:
- Does it contain at least one specific detail that only comes from the angle's human detail?
- Could you swap "SkillsCake" for "AnyAITool" and it still makes sense? If yes, rewrite.
- Is the reading level at or below third grade?
- Does it follow the channel spec for length, format, and tone?
- If it cites a proof point, does that proof point exist in the `skillscake-marketing` proof table?

If a draft fails any of these, fix it before saving.

### Step 3: Present for review

After drafting all posts for the batch:

1. Tell Ryan how many drafts are ready and where they are
2. List them: filename, channel, one-line summary of the angle
3. Ryan will review: **kill** (delete the file), **edit** (change copy or `scheduled_for` inline), or **approve** (say "all set" or similar)
4. Wait for Ryan's go-ahead before scheduling anything

### Step 4: Re-read drafts, then publish

**Before any Typefully or API call, re-read every draft file from disk.** The founder edits drafts between the review step and the publish step: changing copy, moving `scheduled_for` dates, deleting killed files. If you skip this re-read, you will publish stale content on wrong dates. This caused a production mistake and cost manual audit time.

Publish all approved (non-killed) drafts. This is your job — Ryan doesn't touch the UIs.

#### X, LinkedIn, Bluesky (via Typefully)

Typefully is the scheduling/publishing tool for these networks. **Do not invent or restate raw HTTP calls here.** Follow the **`typefully`** skill (see `typefully/SKILL.md` next to this skill) and run its CLI: `<skill-path>/scripts/typefully.js` (or `typefully.js` via the paths in that skill). Official API reference: [typefully.com/docs/api](https://typefully.com/docs/api).

**Auth (same as the typefully skill):** `TYPEFULLY_API_KEY`, or JSON at **`~/.config/typefully/config.json`** with `{"apiKey":"..."}` (not a plain file at `~/.config/typefully` — that path must be a **directory** containing `config.json`), or project `.typefully/config.json`. Priority order is in the typefully skill.

**SkillsCake-specific (this skill owns voice, not mechanics):**
- **X, Bluesky** — SkillsCake brand voice; **LinkedIn** — Agent Horizon voice (see [channel-specs.md](references/channel-specs.md)).
- **Copy once, post wide:** When the angle is a short post (not a LI-specific story), prefer **one** Typefully draft with `--platform x,bluesky` and the same `--text` (after Ryan connects Bluesky in Typefully). UTM on links: use `utm_source` matching the platform you care to attribute, or separate links per channel if you need clean attribution.
- **One draft, different text** when X + LinkedIn differ: use the typefully skill’s **single-draft** pattern (`drafts:create` then `drafts:update` with another `--platform` / `--text`), not two unrelated drafts.
- **X threads:** convert markdown draft text to the format the typefully CLI expects (see **`---` line splits** in the typefully skill).
- **Schedule — `scheduled_for` in draft frontmatter is authoritative.** When scheduling to Typefully, **read each draft file's `scheduled_for` field** and convert it to an ISO datetime for `--schedule`. Never hardcode dates from the calendar table or from memory. The founder edits `scheduled_for` during review; those edits are the final word. If a draft has no `scheduled_for`, use `next-free-slot`. After scheduling, **re-read the draft file** one more time to confirm `scheduled_for` still matches the Typefully `scheduled_date` in the API response. If they differ, reschedule immediately.
- **After scheduling:** add `typefully_id` and `typefully_url` to the file's frontmatter, then **move it to `library/live/`** (see Step 5).

**Engagement / queue:** for “what’s scheduled?” or X analytics ranges, use the **`typefully`** skill’s `analytics` / `queue` commands instead of re-deriving API shapes here.

If Typefully is not configured or the CLI fails, output the drafts in a format Ryan can paste: one file per post with clear channel labels and copy-paste-ready text. Don’t block the pipeline on API issues.

#### Medium (manual only)

**Workflow:**
1. Finish the article as markdown in `library/drafts/` (or `skillscake-product/marketing/medium/` if you keep articles there).
2. Ryan **pastes** into Medium’s editor (or imports markdown if the UI allows), then publishes or saves as draft on medium.com.
3. After it’s live, set `medium_url` on the matching file in **`library/live/`**.

#### Dev.to

**API integration:**
- Dev.to (Forem) API: `https://dev.to/api/`
- Auth: API key in header `api-key`
- Create article: `POST /articles` with `title`, `body_markdown`, `published: false` (always draft first), `tags` (array, max 4)

**Workflow:**
1. Format as markdown. Dev.to supports front matter in the body.
2. Add relevant tags: `ai`, `cursor`, `agents`, `productivity`, etc.
3. Post as draft
4. Tell Ryan the draft is live in Dev.to's editor

If API is not configured, save as markdown ready for paste.

#### API configuration notes

All API keys should be stored in environment variables or a `.env` file that is gitignored. Never hardcode keys in skill files or commit them to the repo. The first time you try to publish and keys aren't set, tell Ryan what keys are needed and where to get them:

| Service | Env var | Where to get it |
|---------|---------|-----------------|
| Typefully | `TYPEFULLY_API_KEY` | [typefully.com/?settings=api](https://typefully.com/?settings=api) — use the **`typefully`** skill + CLI; global file is **`~/.config/typefully/config.json`** (JSON `apiKey`, not a bare file named `typefully`) |
| Medium | — | **Manual only** (paste/publish on medium.com; no API in this workflow). |
| Dev.to | `DEVTO_API_KEY` | dev.to → Settings → Extensions → DEV API Keys. **Not** a plain file at `~/.config/dev.to` — use env, or `~/.config/devto/config.json` with `{"apiKey":"..."}` and `export DEVTO_API_KEY=$(jq -r .apiKey ~/.config/devto/config.json)` (or paste into project `.env`) |

### Step 5: Move to `library/live/`

After scheduling in Typefully:

1. Add `typefully_id` and `typefully_url` to the file.
2. **Move** the file from `library/drafts/` to **`library/live/`** (same filename).
3. Move killed drafts to `library/killed/`.
4. Leave `drafts/` empty when the batch is done.

That is it. No status field. If the file is in `live/`, it is in the pipeline. Ideation mines `library/live/` for history, repeats, and remixes. When Ryan adds engagement notes later, put them directly in the file's frontmatter (`engagement`, `engagement_quality`, `repeat_eligible`).

### Step 6: Tell Ryan what to do manually

After scheduling, **always** end with a short checklist of things only Ryan can do. Examples:

- **LinkedIn first comment:** "Post the link as first comment on LinkedIn Monday Apr 13 around 9 AM ET" (Typefully cannot do this).
- **Medium:** "Paste the article into Medium by [date]."
- **Engagement:** "Reply to any responses on X Monday afternoon."

Do not assume Ryan knows what is manual. Spell it out each time.

## Repeats and remixes

When the angle file includes repeat or remix angles:

**Verbatim repeats:** Repost the exact same content from the library entry. Same text, same format. Only change the date. This is intentional — most followers never saw the original.

**Remixes:** Start from the original content, then modify based on the angle spec's instructions. A remix might change the hook, update a number, add a new detail, or reframe for a different channel.

**Cross-channel adaptation:** An angle that worked on X might be adapted for LinkedIn with an AH-brand voice shift. The core idea stays; the framing changes.

Track reuse in the frontmatter: `reuse_of: library/live/original-filename.md`.

## Ad copy generation

### Google Search (RSAs)

Responsive Search Ads need multiple headlines and descriptions. Google mixes and matches them.

**Constraints:**
- Headlines: max 30 characters each, provide 10-15 variants
- Descriptions: max 90 characters each, provide 3-4 variants
- Pin headline 1 to the brand or core value prop
- Include at least 2 headlines with the keyword the ad group targets

**High-intent keywords for SkillsCake:**
- cursor skills, cursor rules, AI agent skills, improve AI prompts
- agent skill optimizer, skill file, SKILL.md, AGENTS.md
- prompt engineering tool, AI skill builder
- claude code skills, chatgpt custom instructions

**Output format:**

```markdown
---
platform: google-search
campaign: [campaign name]
ad_group: [ad group / keyword theme]
date_created: 2026-04-09
---

## Headlines (30 char max)

1. "Upgrade Your Agent Skills" [pin 1]
2. "Skills? Piece of Cake"
3. "0.14 → 0.79 in 6 Minutes"
4. "Fix Your Cursor Rules"
5. "AI Skills That Actually Work"
6. "Upload. Wait. Done."
7. "First Run Free"
8. "No CLI Required"
9. "Better Skills, Better Agents"
10. "Drop-In Skill Upgrade"

## Descriptions (90 char max)

1. "Upload your skill file. SkillsCake tests and improves it. Ready in minutes."
2. "Works with Cursor, Claude Code, ChatGPT, and 20+ tools. First run free."
3. "Real results: 0.62 to 0.81 in five minutes. No manual iteration needed."
4. "Drag and drop. No install. Your data stays yours. Pay per run, not per month."
```

Save to `skillscake-product/marketing/ads/google/YYYY-MM-DD-adgroup.md`.

### Reddit ads

Reddit display ads targeting dev subreddits.

**Target subreddits:** r/cursor, r/ClaudeAI, r/artificial, r/ChatGPT, r/LocalLLaMA

**Constraints:**
- Headline: max 300 characters (but shorter is better — aim for <100)
- Body text: optional, max 40,000 chars
- CTA: "Learn More" or "Sign Up"
- Reddit users are allergic to corporate-speak. Sound like a person, not a brand.

**Output format:**

```markdown
---
platform: reddit-ads
target_subreddits: [r/cursor, r/ClaudeAI]
date_created: 2026-04-09
---

## Variant 1

**Headline:** Your Cursor rules are the weakest part of your stack
**Body:** Upload them to SkillsCake. Get back rules that actually work. Takes six minutes. First run is free.
**CTA:** Learn More
**Landing:** skillscake.com

## Variant 2

**Headline:** Same AI. Different skill. The skill made the difference.
**Body:** [empty — let the headline do the work]
**CTA:** Learn More
**Landing:** skillscake.com/example/clear-plan
```

Save to `skillscake-product/marketing/ads/reddit/YYYY-MM-DD-variants.md`.

### YouTube video ads

Read [video-ads.md](references/video-ads.md) for the rendering spec. Your job here is to produce the **copy pairs** (hook line + resolution line) that get rendered into minimal text-on-black 5-second videos.

**Output format:**

```markdown
---
platform: youtube-video
date_created: 2026-04-09
---

## Pair 1

- **Hook (page 1):** Re-explaining yourself to your AI?
- **Resolution (page 2):** The fix is here. SkillsCake.

## Pair 2

- **Hook (page 1):** 0.14 → 0.79 in six minutes.
- **Resolution (page 2):** That's a real skill upgrade. SkillsCake.

## Pair 3

- **Hook (page 1):** Your agent is only as good as its skill.
- **Resolution (page 2):** Make it better. SkillsCake.
```

Save to `skillscake-product/marketing/ads/youtube/YYYY-MM-DD-pairs.md`.

#### Ad quality gate

Before saving any ad copy:
- Every claim must be verifiable from the `skillscake-marketing` proof table
- No superlatives without data ("best," "fastest," "most powerful" — unless you can cite the number)
- No competitor names in ad copy (Google policy, Reddit best practice)
- Character counts must be within platform limits
- Landing URLs must point to real pages on skillscake.com

### Ad refresh cadence

Generate 5+ new ad variants per week across all running platforms. The ideation skill's angle file often contains angles that work as ad hooks — look for short, punchy angles with strong proof points.

Also review existing ads: if an ad has been running 3+ weeks, generate fresh variants to prevent fatigue. If an ad's performance data is available in the library, use it to inform which hooks to repeat or retire.

## UTM conventions

All links in scheduled posts and ads should include UTM parameters for attribution.

```
?utm_source=[platform]&utm_medium=[type]&utm_campaign=[campaign]&utm_content=[variant]
```

| Parameter | Values |
|-----------|--------|
| `utm_source` | `twitter`, `bluesky`, `linkedin`, `medium`, `devto`, `google`, `reddit`, `youtube` |
| `utm_medium` | `organic`, `paid`, `social` |
| `utm_campaign` | Descriptive slug: `launch-apr-2026`, `cursor-users`, `skill-upgrade` |
| `utm_content` | Variant identifier: `hook-a`, `thread-1`, `rsa-v3` |

## Content library layout

| Path | What goes here |
|------|---------------|
| `library/drafts/` | WIP — new drafts before scheduling |
| **`library/live/`** | All shipped posts (scheduled or published). **Ideation mines here.** No `*.md` at `library/` root. |
| `library/killed/` | Rejected drafts |

**File naming:** `YYYY-MM-DD-channel-slug.md`. Same name moves `drafts/` → `live/`.

**Frontmatter — keep it minimal.** The folder is the state, not a `status` field.

```yaml
date: 2026-04-09
scheduled_for: 2026-04-13
channel: x
typefully_platforms: x,bluesky
brand: skillscake
angle_ref: calendar/2026-W15-batch.md#angle-3
typefully_id: 8682068
typefully_url: https://typefully.com/?d=8682068&a=296980
```

**Optional** (add when you have the data, not preemptively):

```yaml
reuse_of: library/live/original-filename.md
engagement: "42 likes, 8 replies"
repeat_eligible: true
```

## Working with the brand skill

The `skillscake-marketing` skill is the authority on:
- What claims you can make (proof table)
- Copy anti-patterns (never do these)
- Headline principles
- Voice and tone
- Reading level requirements
- Value equation framing

Read it at the start of every production run. When in doubt about a claim, a tone choice, or a framing decision, the brand skill wins.

The brand skill says what to say and how to say it. This production skill says where to put it, how to format it, and how to ship it.

## Error handling

- **API fails:** If any publishing API fails, save the content as a ready-to-paste file and tell Ryan. Don't silently drop content.
- **Missing angle file:** If there's no angle file in the calendar directory, tell Ryan to run an ideation session first (or offer to run a lightweight one yourself using only the library and seeds).
- **Empty `library/live/`:** During bootstrap, nothing is published yet. That's fine — draft from angles without mining history.
- **Rate limits:** Typefully and Dev.to APIs have rate limits; space calls. Medium is manual (no API). For Typefully, follow the **`typefully`** skill. If you hit a limit, queue the remaining posts and tell Ryan when they'll go out.

## Bootstrap mode (first 2 weeks)

During bootstrap, the founder is investing 2-3 hours/day to seed the library:

- Expect larger angle batches (20-30 angles per ideation session)
- Generate more drafts per day to fill the pipeline
- When engagement data comes in, add `repeat_eligible: true` to give the reuse engine material quickly
- Don’t skip core channels — the goal is to establish presence everywhere in the first two weeks (include **X + Bluesky** when Typefully is connected, plus LinkedIn, Medium, Dev.to as angles allow)
- Ad copy generation can wait until week 3-4 (focus on organic first)
