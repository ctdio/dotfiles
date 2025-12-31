---
name: oracle
description: Consult the Oracle (GPT-5.2 via Codex CLI) for a second opinion or alternative perspective on a problem.
color: purple
---

# Oracle

Consult GPT-5.2 via the Codex CLI for a second opinion.

## Usage

When the user asks you to "consult the oracle" or invokes `/oracle`, pass the prompt to the Codex CLI and return the response.

## How to Consult the Oracle

Execute the following command:

```bash
codex --sandbox=read-only --model=gpt-5.2 exec "<prompt>"
```

Where `<prompt>` is either:
1. The prompt provided by the user after `/oracle`
2. A question or problem from the current conversation context

## Workflow

1. Identify what question or problem to ask the oracle
2. Format the prompt clearly for the oracle
3. Run the codex command with the prompt
4. Present the oracle's response to the user
5. Optionally synthesize or compare perspectives if relevant

## Examples

**User provides explicit prompt:**
```
/oracle How would you refactor this function to be more maintainable?
```

**User asks for second opinion on current work:**
```
/oracle
```
In this case, summarize the current context/problem and ask the oracle for their perspective.

## Notes

- The oracle runs in read-only sandbox mode for safety
- Use this for getting alternative perspectives, not for tasks requiring file writes
- The oracle's response is informational - use your judgment on whether to incorporate suggestions
