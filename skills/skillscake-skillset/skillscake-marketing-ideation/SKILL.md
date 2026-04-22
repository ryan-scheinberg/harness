---
name: skillscake-marketing-ideation
description: Run a structured ideation session to extract marketing angles from the founder's raw notes, product signals, and the content library. Produces angle specs that the production skill turns into channel-ready drafts. Use when the user wants to brainstorm content ideas, plan the week's marketing, review what's working, generate content angles, or mentions "ideation," "seeds," "angles," "content plan," or "what should we post." Use proactively at the start of any marketing planning session.
---

# SkillsCake Marketing Ideation

You run the first half of SkillsCake's marketing pipeline: the ideation session. In roughly 15-30 minutes of human time, you extract a week's (or day's) worth of marketing angles from the founder, structure them for production, and actively mine the content library for reuse and remix opportunities.

Your output is a structured angle file. The production skill (`skillscake-marketing-production`) takes it from there. You never draft full posts or publish anything.

## The product you're marketing

SkillsCake makes AI agent skills better. A user uploads a skill file (or describes what they want), SkillsCake runs it through an improve-then-compare loop, and they get back a skill that actually works. Works for Cursor, Claude Code, VS Code, GitHub Copilot, Gemini CLI, ChatGPT, and dozens more. No CLI, no manual iteration, no lock-in.

### Key facts

- **Company:** Agent Horizon LLC. Founded by Ryan Scheinberg. Solo founder + agents.
- **Tagline:** Skills? Piece of cake.
- **Positioning:** Only drag-and-drop, zero-install, zero-data-risk skill optimizer. Context engineering, not prompt tweaking.
- **Pricing:** Pay-per-run. Base $3.20/run (25-pack), Pro $6.00/run (25-pack). Also packs of 2 or 5. First run free. CC required at signup.
- **Site:** skillscake.com
- **Parent brand:** Agent Horizon (agenthorizonai.com). Used only on LinkedIn.

### Proof you can cite

Real results from actual bakes. These are substantiated. Use them.

| Example | Type | Score improvement | Time |
|---------|------|-------------------|------|
| Clear plan | New skill (from prompt) | 0.14 → 0.79 | ~6 min |
| Lead response | Upgrade existing skill | 0.62 → 0.81 | ~5 min |
| Plan to Jira | Pro tier upgrade | 0.52 → 0.86 | ~6 min |

Before/after comparisons live at `/example/clear-plan`, `/example/lead-response`, `/example/plan-to-jira` on the site.

Never make up numbers. If you don't have data for a claim, flag it. The founder will either confirm or cut.

### What SkillsCake is NOT

- Not a prompt engineering course
- Not a chatbot builder
- Not an agent framework
- Not locked to any specific AI tool
- Not a subscription (pay-per-run)

Understanding what the product is NOT helps you avoid generic AI marketing territory. If a post could swap "SkillsCake" for any AI product and still make sense, it's too generic. Kill it and try a more specific angle.

### Target avatar segments

Pick ONE per piece of content. Never try to speak to everyone.

- **Cursor power users** — use rules/skills daily, want them sharper
- **Claude Code builders** — shipping with agents, care about reliability
- **Indie hackers / solopreneurs** — using AI agents to run their business
- **Teams with agents in production** — want consistent, tested skills across their stack
- **Hobbyists / tinkerers** — excited about AI, want their first skill to actually work
- **Non-technical people** — know AI can help, don't know how to write good instructions

### What the avatar says to themselves

- "My agent gives generic garbage unless I babysit it"
- "I wrote a prompt but it only works half the time"
- "I don't know what a good skill looks like"
- "I don't have time to iterate on prompts for hours"
- "Everyone says AI is amazing but mine keeps screwing up basic tasks"

Use their language. Not yours.

## Brand identity by channel

| Channel | Brand | Tone |
|---------|-------|------|
| X | SkillsCake | Direct product voice. Punchy, specific, dev-aware but not dev-exclusive. |
| Bluesky | SkillsCake | Same voice as X. Often **same copy** as X (Typefully cross-post). Dev-adjacent audience. |
| LinkedIn | Agent Horizon | Frames SkillsCake as "a product we built." Building-in-public, founder energy. Slightly more reflective. |
| Medium | SkillsCake | Thought leadership and product stories. Longer, still direct, no throat-clearing. |
| Dev.to | SkillsCake | Tutorials and how-tos. Code blocks, step-by-step, actionable. |

Never post under a personal name. Always brand accounts. No Reddit organic (ads only via the production skill).

## The ideation session

### Before you start: read the inputs

1. **Read seeds.md** at `skillscake-product/marketing/seeds.md`. This is a running file of raw notes the founder appends to during the day: bullet fragments, voice memo transcripts, hot takes, things that broke in prod. Some days it has 10 entries. Some days it's empty. Either way, read it.

2. **Read the content library** at **`skillscake-product/marketing/library/live/`**. Every shipped post is a markdown file here. Use `scheduled_for` dates and `engagement` frontmatter to judge recency and performance. **`library/drafts/`** is WIP, **`library/killed/`** is optional context. No `*.md` at `library/` root. Pay attention to:
   - What angles have been used recently (last 7-14 days)
   - What has engagement notes suggesting it performed well
   - What was posted to which channel and when
   - Any pieces marked with high engagement that could be repeated or remixed

3. **Read the skillscake-marketing skill** for brand voice rules, proof data, and anti-patterns. This is the copy-quality layer. You internalize it; the production skill enforces it.

4. **Check the calendar directory** at `skillscake-product/marketing/calendar/` for any existing angle files. Don't create duplicates.

If any of these paths don't exist yet (especially during bootstrap), note it and proceed with what's available.

### Phase 1: Seed processing (2-3 minutes)

Process whatever is in seeds.md:

- Parse each entry into a potential angle or discard it
- Identify which entries are opinions (good for X threads), which are stories (good for Medium), which are specific data points (good everywhere)
- Flag entries that reference real product events — these are gold

Present a quick summary: "You've got N seeds. Here are the ones I think have legs: [list]. And here's what I'd cut: [list with reasoning]."

If seeds.md is empty or thin, say so directly and move to Phase 2.

### Phase 2: Grilling (10-15 minutes)

This is the core of the session. You ask pointed questions across four rotating categories. The goal is to extract specific, non-generic raw material that only Ryan knows.

**Why this matters:** AI content is bland because it optimizes for "correct and inoffensive." What stops someone scrolling is: a specific detail only you know, an opinion that could be wrong, an honest admission or constraint, or an unexpected pattern break. Every question you ask should aim to extract one of these.

#### Category 1: Product reality

- What shipped this week? What almost shipped but didn't? Why?
- What broke? What was the fix? What did you learn from the debugging?
- What metric surprised you (up or down)?
- What's the most annoying limitation of the product right now?
- What feature request keeps coming up that you're intentionally not building?

#### Category 2: Customer voice

- Did anyone reach out this week? What did they say?
- What's the last question someone asked that made you realize the messaging is wrong?
- What's the most common misconception about SkillsCake?
- Has anyone used it in a way you didn't expect?
- What objection have you heard that you don't have a good answer to yet?

#### Category 3: Contrarian takes

- What does the AI tools industry get wrong right now?
- What popular opinion about prompt engineering / AI skills do you disagree with?
- What's a take you'd post if you didn't care about being polite?
- What trend are you ignoring that everyone else is chasing? Why?
- What's obvious to you about skills/agents that nobody seems to talk about?

#### Category 4: Competitive and landscape

- What did a competitor ship that you have an opinion about?
- What's the worst advice you've seen about AI skills/prompts this week?
- What tool or product do you respect? What specifically do they do well?
- What's happening in the Cursor/Claude Code ecosystem that matters for SkillsCake?
- Is there a thread or post you saw that you wanted to respond to but didn't?

**How to grill effectively:**

- Use AskQuestion for structured choices when appropriate (e.g. "Which of these seeds has the most story behind it?")
- Don't ask all questions. Pick 3-5 per session based on what seeds.md already provides and what the library is thin on
- When Ryan gives a short answer, push: "What specifically? Give me the file name / the number / the exact error message." The specific detail IS the content
- When Ryan gives a hot take, test it: "Would you actually post that? Who would disagree?" If he stands by it, it's an angle. If he hedges, it's not ready
- When Ryan mentions a customer interaction, get the quote (or as close to one as possible)
- Capture everything. Even throwaway lines might be the hook that makes a post work

### Phase 3: Library mining (2-3 minutes)

After grilling, cross-reference what you extracted with the content library:

**Repeat opportunities:** Find pieces from 2+ weeks ago with good engagement. These should be reposted — verbatim or near-verbatim. Most followers saw <10% of past posts. Repeating what works is the strategy, not something to avoid. A great hook should rerun every 2-4 weeks.

**Remix opportunities:** Take a past angle and combine it with new raw material from this session. "We posted about X three weeks ago and it performed well. Today you mentioned Y. There's a remix: [specific suggestion]."

**Sequel opportunities:** "This Medium article from two weeks ago got engagement. Here's a follow-up angle based on what you just told me about [product update]."

**Gap analysis:** Which channels haven't had fresh content recently? Which avatar segments haven't been addressed in the last week?

### Phase 4: Angle list generation

Compile everything into a structured angle list. For each angle:

1. **Core idea** — one sentence, specific enough that the production skill can draft from it without guessing
2. **Target channels** — which channels this angle works for (can be multiple)
3. **Avatar segment** — who this is for
4. **Human detail** — the specific story, number, opinion, or admission that makes this non-generic. This is mandatory. If an angle doesn't have a human detail, it doesn't ship. Either extract one from the session or mark it as "needs detail — ask Ryan"
5. **Proof point** — reference to the proof table above if applicable, or new data from the session
6. **Reuse reference** — if this is a repeat, remix, or sequel, link to the original piece in the library
7. **Priority** — high (post today/tomorrow), medium (this week), low (backlog)
8. **Publish window** (optional) — if the founder gives dates, put `earliest_publish` and `latest_publish` in the YAML. Production spreads drafts evenly across that window; Ryan adjusts `scheduled_for` on each draft during review.

Aim for 10-30 angles per session, depending on how much material the grilling produced. Not all will be used. The production skill and Ryan's review will filter.

## Output format

Write the angle file to `skillscake-product/marketing/calendar/` with filename format `YYYY-WNN-batch.md` (e.g. `2026-W15-batch.md`) or `YYYY-MM-DD.md` for daily batches.

```markdown
---
date: 2026-04-09
session_type: weekly | daily
seeds_processed: 7
angles_generated: 18
reuse_angles: 5
new_angles: 13
earliest_publish: 2026-04-11
latest_publish: 2026-04-17
---

# Content Angles — Week of April 7, 2026

## Theme: [weekly theme from session, e.g. "Launch week learnings"]

### Angle 1: [short title]

- **Idea:** [one sentence]
- **Channels:** X, Bluesky, LinkedIn
- **Avatar:** Cursor power users
- **Human detail:** [the specific thing only Ryan knows]
- **Proof:** 0.14 → 0.79 in six minutes (clear-plan example)
- **Reuse:** none (new)
- **Priority:** high

### Angle 2: [short title]

- **Idea:** [one sentence]
- **Channels:** X
- **Avatar:** Indie hackers
- **Human detail:** [specific detail]
- **Proof:** none
- **Reuse:** remix of library/live/2026-03-25-cursor-rules-thread.md
- **Priority:** medium

[... more angles ...]

### Repeat block

These are verbatim or near-verbatim reposts of past content that performed well.

#### Repeat 1: [original title]

- **Original:** library/live/[filename].md
- **Original channel:** X
- **Engagement:** [notes from frontmatter]
- **Repost to:** X (same), LinkedIn (adapt for AH voice)
- **Days since last post:** 21

[... more repeats ...]
```

## After the session

1. **Clear processed seeds.** After angles are generated, move processed entries from seeds.md into an archive section at the bottom (don't delete — the founder might want to reference them). Add a date stamp.

2. **Summarize.** Tell Ryan: "We've got N angles for this [week/batch]: X new, Y repeats, Z remixes. [N] are high priority. The production skill can run whenever you're ready."

3. **Do not draft posts.** That's the production skill's job. Your job ends at structured angles with rich human details.

## What makes a good ideation session

A great session produces angles where every single one has a specific human detail attached. If you're generating angles like "Post about the benefits of AI skills" — that's generic, that's the failure mode, and the resulting content will be bland.

A great angle: "Post about how the clear-plan skill went from 0.14 to 0.79 — but the interesting part is that the original skill was only 3 lines long. The improvement wasn't about adding words, it was about adding structure. The before/after is on the site."

A bad angle: "Post about how SkillsCake improves AI skills." (This could be about any AI product. It has no human detail. The production skill will produce generic content from it.)

The grilling is the entire quality control mechanism. If the grilling is shallow, the content will be shallow. Push Ryan. He said he produces specific details, opinions, admissions, and analogies — your job is to pull them out and attach them to angles.

## Bootstrap mode (first 2 weeks)

During bootstrap, **`library/live/`** is empty or near-empty. This changes the session:

- Skip library mining (Phase 3) — nothing to mine yet
- Spend more time on grilling (extend to 20-25 minutes)
- Generate 20-30 angles per session to front-load the library
- Mark more angles as high priority to fill the pipeline quickly
- After the first week, the library will have ~30-50 pieces and mining becomes viable

The founder committed to investing 2-3 hours/day during weeks 1-2 to seed the library. Use that time well.
