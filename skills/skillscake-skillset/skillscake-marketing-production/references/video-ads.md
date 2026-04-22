# Video Ad Rendering Spec

Minimal text-on-black video ads for YouTube. No talking head, no screen recording, no AI-generated faces. Just typography on a dark background. These are 5-second bumper ads.

## The concept

Inspired by ultra-minimal direct-response ads: two pages of text, black background, clean sans-serif type. Page 1 is a hook (problem or question). Page 2 is the resolution (answer + brand). Total runtime: 5 seconds.

The power is in the copy, not the production. The production skill generates the copy pairs; this spec handles rendering them into .mp4 files.

## Visual spec

| Property | Value |
|----------|-------|
| Resolution | 1920x1080 (16:9 for YouTube) |
| Background | Pure black (#000000) |
| Text color (hook) | White (#FFFFFF) or light blue (#60A5FA) |
| Text color (resolution) | White (#FFFFFF) |
| Brand color | SkillsCake pink (#E91E8C) for "SkillsCake" brand name only |
| Font | Inter, weight 600 (semibold) for hook; weight 700 (bold) for brand name |
| Font size | Hook: 64-80px depending on line length. Brand: 72px. |
| Text alignment | Centered, vertically and horizontally |
| Page 1 duration | 2.5 seconds |
| Page 2 duration | 2.5 seconds |
| Transition | Hard cut (no fade, no animation — keep it raw) |
| Audio | None (YouTube will overlay their own if needed) |

## Rendering with FFmpeg

Generate a .mp4 from a copy pair using FFmpeg's drawtext filter.

```bash
#!/bin/bash
HOOK="Re-explaining yourself to your AI?"
RESOLUTION="The fix is here."
BRAND="SkillsCake."

ffmpeg -y \
  -f lavfi -i color=c=black:s=1920x1080:d=2.5 \
  -f lavfi -i color=c=black:s=1920x1080:d=2.5 \
  -filter_complex "
    [0:v]drawtext=text='${HOOK}':fontfile=/path/to/Inter-SemiBold.ttf:fontsize=72:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2[v0];
    [1:v]drawtext=text='${RESOLUTION}':fontfile=/path/to/Inter-SemiBold.ttf:fontsize=64:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2-50,
    drawtext=text='${BRAND}':fontfile=/path/to/Inter-Bold.ttf:fontsize=72:fontcolor=#E91E8C:x=(w-text_w)/2:y=(h-text_h)/2+50[v1];
    [v0][v1]concat=n=2:v=1:a=0[out]
  " \
  -map "[out]" -c:v libx264 -pix_fmt yuv420p output.mp4
```

**Notes:**
- Replace `/path/to/Inter-*.ttf` with the actual font path. Download Inter from Google Fonts if not installed.
- For multi-line hooks, use line breaks in the drawtext command or split into multiple drawtext filters stacked vertically.
- If the hook is longer than ~40 characters, reduce font size to 56-64px to prevent clipping.

## Rendering with Remotion (alternative)

If a programmatic pipeline is preferred, use Remotion (React-based video generation):

```typescript
// composition config
{
  id: "bumper-ad",
  width: 1920,
  height: 1080,
  fps: 30,
  durationInFrames: 150, // 5 seconds at 30fps
}
```

Each frame renders a React component: frames 0-74 show the hook text, frames 75-149 show the resolution + brand. Style with CSS (Inter font, centered flex, black bg, white/pink text).

Render: `npx remotion render BumperAd out/ad.mp4 --props='{"hook":"...","resolution":"...","brand":"SkillsCake."}'`

## Copy pair quality rules

Before rendering, check the copy pair:

1. **Hook must be a question or a specific claim.** "Better AI skills" is not a hook. "Re-explaining yourself to your AI?" is.
2. **Resolution must include the brand.** Always end with "SkillsCake." (with period).
3. **Total word count across both pages: under 20.** These are 5-second ads. Every word must earn its frame time.
4. **No unverifiable claims.** Same rules as the brand skill.
5. **Hook should work with no context.** Someone skipping YouTube ads sees the hook for 1-2 seconds. It must land instantly.

## File organization

Save rendered videos to `skillscake-product/marketing/ads/youtube/renders/`.
Filename: `YYYY-MM-DD-pair-N.mp4` (e.g. `2026-04-09-pair-1.mp4`).

Keep the copy pairs file (from the production skill) alongside as the source of truth. The video file is a build artifact.

## YouTube ad specs (for upload)

| Setting | Value |
|---------|-------|
| Campaign type | Video (Bumper) |
| Ad format | Bumper ad (6 seconds max, non-skippable) |
| Duration | 5 seconds (within 6-second bumper limit) |
| File format | .mp4, H.264 |
| Max file size | 10MB (these will be <1MB) |
| Targeting | Interest: Technology, Software; Keywords from RSA keyword list |
| Bid strategy | Target CPM (maximize impressions at budget) |
