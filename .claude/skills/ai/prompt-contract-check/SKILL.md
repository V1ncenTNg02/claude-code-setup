# Skill: Prompt Contract Check

---

## When to invoke

Use this skill when:
- Writing or modifying any LLM prompt used in production
- Changing system prompts, few-shot examples, or output format instructions
- Adding a new LLM call to the application

---

## Prompt as a contract

A prompt is a contract between your application and the LLM.
The contract includes: input structure, behavioral instructions, and output format.
Breaking any part of the contract silently breaks downstream parsing.

---

## Prompt structure checklist

- [ ] System prompt defines the model's **role** and **constraints** unambiguously
- [ ] Output format is explicitly specified (JSON, markdown, plain text)
- [ ] JSON output: provide the exact schema in the prompt; use structured output / function calling where available
- [ ] Output format instructions are in the system prompt, not buried in the user turn
- [ ] Few-shot examples demonstrate the exact format required
- [ ] Negative examples included if there are common failure modes to prevent

---

## Input validation

- [ ] All user-supplied values are clearly delimited in the prompt (use XML tags, quotes, or explicit delimiters)
- [ ] Prompt injection risk assessed: user input must not be able to override system instructions
- [ ] Template variables validated before interpolation — no `undefined` or `null` interpolated silently

```
// Safe prompt construction — delimit user input
System: You are a summarizer. Summarize only the text inside <document> tags.
User: <document>{sanitized_user_content}</document>
Summarize the above in 3 bullet points.
```

---

## Output parsing contract

- [ ] Output parser is resilient to minor formatting variation (extra whitespace, trailing comma)
- [ ] Parser validates required fields before using them
- [ ] Fallback defined for parse failures — do not crash, return a structured error
- [ ] JSON mode / structured output used if the model supports it (eliminates most parse failures)

---

## Model version pinning

- [ ] Model version pinned in configuration: `claude-sonnet-4-6`, not `claude-latest`
- [ ] Prompt tested against the specific pinned version
- [ ] Model upgrade treated as a breaking change: re-test all prompts after upgrade

---

## Cost and latency contract

- [ ] Token budget estimated for typical inputs
- [ ] Max tokens set to prevent runaway generation
- [ ] Streaming used for user-facing responses > 500 tokens
- [ ] Prompt caching enabled for stable system prompts (Anthropic: use cache breakpoints)

---

## Change management

When modifying a prompt:
1. Run the existing golden test set against both old and new prompts.
2. Diff the outputs — any behavioral change must be intentional.
3. Document the change and why in the PR description.
4. Update the golden test set with new expected outputs.

Never modify a production prompt without a golden test comparison.
