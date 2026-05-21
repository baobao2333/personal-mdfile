---
name: market-research-flow
description: Use when researching a market, product category, competitor set, or growth opportunity that needs current data, source triangulation, historical context, and a decision-grade recommendation. Especially useful for mobile games, app-store charts, ad-monetized products, overseas market entry, and questions like what to build, what to avoid, why a product is working now, or whether a seeming white space is real.
---

# Market Research Flow

## Overview

Use this skill to turn a broad research question into a decision-ready market report. The workflow treats data as the spine, history as context, and absence of competitors as a hypothesis to challenge rather than an automatic opportunity.

## Decision Contract

The output must be a result, not a research guide. If the user asks what to do, choose a winner.

Start every report with a `Decision` block:

```text
Decision: [one concrete choice]
Confidence: [High / Medium / Low]
Why this wins: [one sentence]
What would change my mind: [one sentence]
```

Then provide:

- `Ranked options`: exactly one primary recommendation, one backup, and one reject list unless the user asks for more.
- `Evidence table`: concrete products, markets, dates, ranks, downloads, revenue, ratings, or other hard signals.
- `Why not the alternatives`: explain why the runner-up and rejected paths lose.
- `Execution implication`: what the user should build, test, monitor, or avoid next.

Do not let the report end as a checklist. If a test plan is useful, put it after the decision and make it serve the chosen recommendation.

## Anti-Patterns

- Do not answer with broad categories such as "Puzzle / Sort / Arcade" without picking the specific category or product pattern that wins.
- Do not list benchmarks without saying which one should be copied, avoided, or only monitored.
- Do not replace the conclusion with a generic validation framework.
- Do not say "feasible" without naming the exact thing most worth doing.
- Do not call a market gap an opportunity before checking failed or small variants.
- Do not hide behind uncertainty. If evidence is incomplete, give a provisional decision and state what data would overturn it.

## Core Workflow

1. **Pin down the decision.**
   - State the user's actual decision: build, copy, avoid, prioritize, launch, or monitor.
   - Name the market, geography, platform, monetization model, and time window.
   - If the user did not specify geography, do not default to one country. Choose a reasonable country set and say why.

2. **Build the data spine first.**
   - Gather current quantitative signals before writing conclusions.
   - Prefer rankings, downloads, ratings, release dates, revenue/grossing rank, review counts, ad creatives, store metadata, and local generated reports.
   - Keep exact dates in the report. For current-market questions, browse and cite sources.
   - Separate weak signals such as free-chart rank from stronger signals such as grossing rank, sustained rank, multi-market coverage, or verified download milestones.

3. **Create the competitor universe.**
   - Include the obvious direct competitors, older benchmark products, and recent entrants.
   - Split them into cohorts:
     - `benchmarks`: old or durable products that show the ceiling and moat.
     - `new opportunities`: products released recently, usually within 90 days unless another window is justified.
     - `failed or small variants`: products that tried a nearby angle but did not scale.
   - Do not discard weak variants. They are useful evidence for why an apparent gap may be hard.

4. **Trace the history.**
   - Identify the earliest known mechanic ancestor, earliest mobile expression, first breakout hit, and latest breakout.
   - Distinguish mechanism lineage from packaging lineage.
   - Use history to explain why a pattern works now, not just where it came from.

5. **Triangulate sources.**
   - Use at least two independent source types when possible:
     - store pages and rankings,
     - publisher announcements,
     - app-intelligence or ad-intelligence reports,
     - gameplay videos,
     - reviews and walkthrough sites,
     - academic or historical references for old mechanics.
   - Do not rely only on official store descriptions. Use gameplay evidence to verify the actual loop.
   - Mark publisher PR claims as claims unless independently corroborated.

6. **Run the "why not" check.**
   - Before calling a white space an opportunity, search for products that tried the same replacement, packaging, mechanic, or market.
   - If similar attempts exist but are small, treat that as negative evidence.
   - Ask: why might others have avoided or failed at this angle?
   - Consider search keywords, user comprehension, ad-material clarity, genre expectations, art cost, localization burden, and monetization fit.

7. **Explain the current winner.**
   - Explain what the product did right in product terms, not just that it ranked.
   - Cover:
     - first-screen comprehension,
     - ad creative readability,
     - failure tension and rescue points,
     - level-generation depth,
     - market fit by geography,
     - monetization fit,
     - differentiation from prior hits.

8. **Give a decision, not just a summary.**
   - End with a clear recommendation: copy the mechanic, copy the packaging, monitor, avoid, or test only in creatives.
   - Include what not to copy.
   - Include the first test market, target metric, and biggest risk when relevant.

## Report Shape

Use this structure unless the user asks for another format:

```text
Decision
Ranked Options
Data Spine
History
Competitor Map
Why It Works Now
Why Others Did Not Do It
Why The Winner Wins
Why Alternatives Lose
Risks And Next Tests
Sources
```

For market-entry or build/avoid questions, include a compact scoring table:

```text
Option | Data strength | Market fit | Monetization fit | Differentiation | Execution risk | Score | Verdict
```

The highest score is not automatically the recommendation. Explain any override.

## Evidence Rules

- Use absolute dates for launches, milestones, and source publication dates.
- Cite sources for current facts, rankings, downloads, release dates, and market claims.
- Clearly label inference, especially when deriving opportunity from rankings or store metadata.
- Do not overstate global opportunity from one country.
- Do not overstate ad-monetization potential from grossing rank alone; it may indicate IAP strength instead.
- Do not infer that a different wrapper will work because it is uncommon. First look for failed or small examples.

## Output Style

- Lead with the actionable answer.
- Keep tables compact and tied to the decision.
- Use short product-language bullets for reasoning.
- Preserve uncertainty where evidence is thin.
- Prefer "I would build X, not Y" over "there are several promising directions".
- For Chinese users, write the report in Chinese while keeping product names, file names, and technical terms exact.
