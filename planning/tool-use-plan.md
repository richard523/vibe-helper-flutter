# Plan: Tool-Use Rendering Fix + Chronological Session Order

Branch: `tool-use`

## Problem 1 — Tool-use assistant messages render as blank

### Root cause
`SessionMessage.fromJson` (lib/models/message.dart) expects fields that do
not exist in the actual `messages.jsonl` format:

| Parser expects          | Actual field                                    |
|------------------------|-------------------------------------------------|
| `json['tool_name']`    | `tool_calls[].function.name`                     |
| `json['tool_arguments']`| `tool_calls[].function.arguments`              |
| `json['tool_result']`  | `content` on `{"role":"tool"}` messages         |
| `json['tool_success']` | (not present — infer from content)              |
| `json['tool_call_id']` | `tool_call_id` on tool messages (correct)        |

An assistant tool-call line looks like:
```json
{"role":"assistant","content":"","tool_calls":[{"id":"X","function":{"name":"grep","arguments":"{...}"},"type":"function"}]}
```
Because `content` is `""` and `json['tool_name']` is null, `isToolCall`
returns false, so the message falls through to the assistant branch and
renders as a blank green "Assistant" card.

A tool-result line looks like:
```json
{"role":"tool","content":"...output...","name":"grep","tool_call_id":"X"}
```
This has `role:"tool"` (neither user nor assistant) and a `name` field the
parser never reads, so it also renders incorrectly.

### Fix
**lib/models/message.dart**
- Parse `tool_calls` array: if present and non-empty, extract
  `function.name` -> `toolName`, `function.arguments` -> `toolArguments`
  (JSON-decode the string arguments into a Map).
- Parse role `"tool"` messages: `name` -> `toolName`, `content` ->
  `toolResult`, `tool_call_id` -> `toolCallId`.
- New getters:
  - `isToolRequest`  — assistant message with tool_calls (toolName != null && role == assistant)
  - `isToolResult`   — role == "tool"
- Infer `toolSuccess`: true unless content contains `<tool_error>` /
  `<user_cancellation>`.
- Store `reasoningContent` for optional future display.

## Problem 2 — Distinct color for tool usage

### Fix
**lib/screens/session_detail_screen.dart** `_buildMessageCard`:
- Tool request  (assistant invokes tool) -> **amber** (`Colors.amber`)
- Tool result  (tool output)            -> **deep orange** (`Colors.deepOrange`)
- User                                        -> blue (unchanged)
- Assistant (text)                            -> green (unchanged)

Render logic:
- Tool request: show tool name as label + arguments block.
- Tool result:  show tool name + truncated result; green text on success,
  red on error.
- Assistant with `content` non-empty AND tool_calls: show both the text
  and the tool-call block.

## Problem 3 — Sessions not in chronological order

### Root cause
`session_loader.dart:66` sorts descending (`b.startTime.compareTo(a.startTime)`
= newest first). The user wants chronological = ascending (oldest first).

### Fix
**lib/services/session_loader.dart:66** — flip comparator to
`a.startTime.compareTo(b.startTime)`.

## Files changed
1. lib/models/message.dart — parsing + getters
2. lib/screens/session_detail_screen.dart — color + render branches
3. lib/services/session_loader.dart — sort direction
4. test/widget_test.dart — replace default counter test with message-parse test

## Testing
Run: `flutter test`
