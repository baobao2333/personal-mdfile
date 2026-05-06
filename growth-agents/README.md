# Growth Agents

These Markdown files define the local agents used by the Growth app.

The server reads these files at runtime before calling Hermes, then appends the required JSON schema and current app context. Edit the agent files here when you want to change behavior without touching TypeScript code.

- `planner-agent.md`: daily planning and stage plan normalization.
- `grader-agent.md`: practice grading and follow-up drill generation.
- `memory-agent.md`: durable learning memory extraction.
- `report-agent.md`: daily learning brief generation.
- `review-agent.md`: weekly review and stage completion audit.
- `coach-agent.md`: direct chat and plan adjustment.
