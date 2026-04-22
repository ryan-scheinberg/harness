# Channel Specifications

Format constraints, tone adjustments, and structural rules for each publishing channel. The production skill references this file when drafting posts.

All channels follow the `skillscake-marketing` brand voice (read it first). This file covers channel-specific deviations only.

---

## X (Twitter) — SkillsCake brand

### Single tweets

- **Max length:** 280 characters. Aim for 200-250 (leaves room for engagement).
- **Structure:** Hook → proof or detail → CTA or punchline. That's it.
- **Hashtags:** 0-2 max. Only if genuinely relevant: #CursorAI, #ClaudeCode, #AISkills, #AgentSkills. Never #AI #MachineLearning #Innovation (too broad, signals spam).
- **Links:** One link max. Place at the end. Use UTM parameters.
- **Tone:** Punchy, direct, slightly informal. "We" not "SkillsCake" (the account IS SkillsCake).
- **Images:** Optional. If including a before/after score comparison, use a clean screenshot or a text card.

**Example (good):**
```
Your Cursor rules are probably the weakest part of your stack.

We took a 3-line skill and turned it into one that scores 0.79.

Took six minutes.

skillscake.com/example/clear-plan
```

**Example (bad):**
```
🚀 Exciting news! SkillsCake is revolutionizing the way developers optimize their AI agent skills! Our cutting-edge platform leverages advanced context engineering to deliver unparalleled results. Try it today! #AI #Innovation #Skills
```

### X threads

- **Thread length:** 3-7 tweets. Sweet spot is 4-5.
- **Tweet 1 (hook):** Must stand alone. If someone only sees tweet 1, they should understand the value prop or be compelled to read more. No "Thread:" or "1/" prefix.
- **Tweet 2-N:** One idea per tweet. Each should make sense if read in isolation (people scroll in and out of threads).
- **Last tweet:** CTA with link. Keep it short.
- **Separator in draft files / Typefully:** Use a line with only `---` between posts (see **`typefully`** skill). The same short post can also ship to **Bluesky** when cross-posting (see Bluesky section).

**Thread structure patterns that work:**
- Problem → insight → proof → CTA
- "I did X. Here's what happened." (story thread)
- Contrarian take → evidence → "here's what I'd do instead" → CTA
- Listicle: "5 things I learned about X" (one per tweet)

### Engagement posts (replies, quote tweets)

- Only draft these if the angle spec specifically references a conversation to join
- Keep under 200 characters
- Add value, don't just promote. "This is exactly why we built [specific feature]" is fine. "Check out SkillsCake!" is spam.

---

## Bluesky — SkillsCake brand

Same **product voice** as X. Default: **same copy** as X for single posts.

- **Max length:** 300 characters per post (Typefully). X posts (≤280) usually fit unchanged.
- **Audience:** Often dev- and OSS-adjacent; still avoid jargon walls.
- **Links / UTMs:** `utm_source=bluesky`.
- **When to post:** Connect **Bluesky** in Typefully; `--platform bluesky` or `x,bluesky` for one draft with the same `--text` when content matches.

---

## LinkedIn — Agent Horizon brand

### Identity shift

On LinkedIn, the posting brand is **Agent Horizon**, not SkillsCake. The framing is "a product we built" — SkillsCake is referenced as a case study, not as the main character.

| SkillsCake voice (X/Bluesky/Medium/Dev.to) | Agent Horizon voice (LinkedIn) |
|-------------------------------------|-------------------------------|
| "We upgraded a skill from 0.14 to 0.79" | "We built a tool that takes a rough skill file and returns one that scores 0.79" |
| "Upload your skill" | "We wanted to solve the skill quality problem, so we built SkillsCake" |
| "Skills? Piece of cake." | "What we learned building an AI skill optimizer" |

### Format

- **Max length:** 3,000 characters. Aim for 1,000-1,500 for regular posts, 2,000-2,500 for thought leadership.
- **Structure:** Hook line (first line visible before "see more") → 2-3 short paragraphs → insight or lesson → soft CTA.
- **The "see more" fold:** LinkedIn truncates after ~210 characters on desktop, ~150 on mobile. The first line must compel the click. This is the most important line in the post.
- **Line breaks:** Use single line breaks between every 1-2 sentences. LinkedIn's algorithm and readability both favor short visual paragraphs. Wall-of-text posts get scrolled past.
- **Hashtags:** 3-5 at the end. #AIAgents #BuildInPublic #Cursor #ClaudeCode #IndieHacker (pick relevant ones per post).
- **Links:** LinkedIn deprioritizes posts with links. Strategy: put the link in the FIRST COMMENT, not in the post body. Mention "link in comments" or "details in comments" in the post.
- **Tone:** Slightly more reflective than X. Founder-building-in-public energy. "Here's what I learned" > "Here's what you should do."

**Example (good):**
```
We spent three weeks building a skill optimizer.

The hardest part wasn't the AI pipeline.

It was figuring out what "better" means for a skill file that could run in Cursor, Claude Code, ChatGPT, or any of 20+ tools.

Here's what we landed on:

A skill is better when it gets the agent to do the right thing in more situations, not just the test case.

So we built a comparison loop. Original skill vs improved skill, tested against scenarios the user didn't think of.

SkillsCake runs it automatically. Upload a skill, get a better one back in six minutes.

The improvement on our first public example: 0.14 to 0.79.

Details in comments.

#AIAgents #BuildInPublic #AgentSkills
```

**Example (bad):**
```
Excited to announce SkillsCake! 🎂 Our AI-powered platform optimizes your agent skills with cutting-edge technology. Whether you're a developer or hobbyist, SkillsCake makes your AI better. Link: skillscake.com #AI #Startup #Launch
```

---

## Medium — SkillsCake brand

**Publishing:** Draft in markdown here; **post manually** in Medium’s editor (paste or import if supported).

### Format

- **Article length:** 800-2,000 words. Sweet spot is 1,200-1,500.
- **Title:** Clear, specific, front-loads the value. "How a 3-Line Skill File Became a Working Agent in 6 Minutes" > "The Power of AI Skills."
- **Subtitle:** Optional but recommended. One sentence that adds context or a contrarian angle.
- **Structure:**
  - Strong opening paragraph (the lede — states the core insight or story in 2-3 sentences)
  - Context section (the problem, 2-3 paragraphs)
  - The core content (the insight, the walkthrough, the argument — 4-8 paragraphs)
  - Conclusion (1-2 paragraphs, CTA)
- **Headers:** Use H2 for main sections, H3 for subsections. Headers should be descriptive, not clever. "What we changed" > "The secret sauce."
- **Code blocks:** If showing skill files or agent output, use fenced code blocks with syntax highlighting.
- **Images:** Before/after comparisons are the strongest visual for SkillsCake content. Score deltas rendered as simple graphics.
- **CTA:** End with a soft CTA. "If you want to try this on your own skill, SkillsCake runs your first bake for free." Not "SIGN UP NOW."
- **Tags:** 5 max. Relevant: `artificial-intelligence`, `developer-tools`, `productivity`, `cursor`, `prompt-engineering`.
- **No canonical URL** (Medium IS the blog. No cross-post from site.)

### Content types that work on Medium

1. **Before/after stories:** Take a real bake result and narrate the transformation. Include the actual skill content if possible.
2. **Educational/explanatory:** "What is a skill file and why your AI needs one." Teaches a concept and positions SkillsCake as the solution.
3. **Contrarian takes:** "Prompt engineering is dead. Context engineering is what matters." (Only if the founder actually holds this opinion.)
4. **Walkthroughs:** Step-by-step of a specific use case. "I built a Cursor skill for code review in 10 minutes using SkillsCake."

### Tone

Same as X but with room to breathe. Medium readers expect some depth. You can develop an idea over multiple paragraphs without losing them. Still: no throat-clearing, no academic hedging, no corporate polish. Write like a smart friend explaining something at a whiteboard.

---

## Dev.to — SkillsCake brand

### Format

- **Article length:** 500-1,500 words. Shorter than Medium. More code, less prose.
- **Title:** Tutorial-style. "How to [Specific Action] with [Tool/Stack]." Clear about what the reader will learn.
- **Tags:** Max 4. `ai`, `cursor`, `productivity`, `tutorial` (pick the most relevant).
- **Structure:**
  - One-paragraph intro: what you'll build/learn, why it matters
  - Prerequisites (if any): tools, accounts, versions
  - Step-by-step walkthrough with code blocks
  - Results and output
  - Wrap-up (1-2 sentences, soft CTA)
- **Code blocks:** Heavy use. Show actual file contents, commands, outputs. Dev.to readers want to follow along.
- **Tone:** Casual dev-to-dev. "Alright, here's how this works." First person is fine.
- **Series:** If a topic needs multiple articles, use Dev.to's series feature.

### Content types that work on Dev.to

1. **Tutorials:** "How to Write a Cursor Skill That Actually Works" — step by step, code blocks, practical.
2. **Tool comparisons:** "I Tested 3 Ways to Improve My Agent Skills. Here's What Worked." (Honest, data-backed.)
3. **TIL posts:** Short "today I learned" posts about skill file structure, edge cases, or quirks.
4. **Explainers:** "What's the Difference Between a Prompt and a Skill?" — educational, positions SkillsCake naturally.

### Separate from Medium

Dev.to content is NOT cross-posted from Medium. The audiences and formats are different:

| | Medium | Dev.to |
|---|--------|--------|
| Audience | Broader tech/AI | Developer-specific |
| Tone | Thought leadership | Practical how-to |
| Length | 1,200-1,500 words | 500-1,200 words |
| Code | Supplementary | Central |
| Framing | Ideas and insights | Steps and outputs |

Same topic can appear on both, but the article should be rewritten for each audience. A Medium piece on "why skills matter" becomes a Dev.to piece on "how to write your first skill."

---

## Channel-specific rules summary

| Rule | X | Bluesky | LinkedIn | Medium | Dev.to |
|------|---|---------|----------|--------|--------|
| Brand | SkillsCake | SkillsCake | Agent Horizon | SkillsCake | SkillsCake |
| Max length | 280/tweet | 300/post | 3,000 chars | 2,000 words | 1,500 words |
| Links in body | Yes | Yes | No (put in comment) | Yes | Yes |
| Hashtags | 0-2 | 0-2 | 3-5 | Tags (5) | Tags (4) |
| Em dashes | No | No | No | No | No |
| Code blocks | Rare | Rare | Never | Sometimes | Heavy |
| Reading level | 3rd grade | 3rd grade | 3rd grade | 5th grade OK | 5th grade OK |
| CTA style | Direct link | Direct link | "Link in comments" | Soft end-of-article | Soft end-of-article |
| Post frequency | 5-8/day | same as X when cross-posting | 1-2/day | 2-3/week | 1-2/week |
| Typefully | Yes | Yes | Yes | No (Medium: manual) | No (Dev.to API) |
