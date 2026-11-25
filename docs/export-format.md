# Export formats

S41 saves `ctrltask-YYYY-MM-DD.csv` or `ctrltask-YYYY-MM-DD.json` (today's local date) through the share sheet. Both formats are UTF-8. Nothing leaves the phone any other way (PRD §9).

## What's included

The options on S41 apply to both formats:

| Option | Effect |
|---|---|
| **Range** (All time, This year, Custom range) | Tasks **created** in the range, and focus sessions **started** in it, by local day with both ends included. Projects, tags and settings are kept whole. |
| **Completed tasks** (on) | Off leaves out done tasks. |
| **Archived projects** (off) | Off leaves out archived projects and every task in them. |
| **Focus sessions** (on) | Off leaves out every focus session. CSV never has sessions. |

The totals line on S41 counts what the file will hold. For CSV it shows tasks and projects only.

## CSV: tasks

There's one header row, then one row per task, in the order the tasks were created. Values are quoted when they contain a comma, a quote or a line break, and quotes are doubled (RFC 4180).

| Column | Format | Example |
|---|---|---|
| `title` | text | `Review wireframes` |
| `status` | `open` or `done` | `open` |
| `priority` | `urgent`, `high`, `medium` or `low` | `high` |
| `due_date` | `YYYY-MM-DD`, empty if none | `2026-11-19` |
| `due_time` | `HH:MM` (24-hour), empty if none | `09:05` |
| `project` | the project's name, empty for Inbox | `Website redesign` |
| `tags` | names separated by `;` | `design;client` |
| `repeat` | the rule as S15 reads it, empty if none | `Every Mon, Thu` |
| `created_at` | ISO 8601 in UTC | `2026-11-02T08:15:00.000Z` |
| `completed_at` | ISO 8601 in UTC, empty if open | `2026-11-03T10:00:00.000Z` |
| `description` | text, which may span lines | `Check the mobile layout` |

## JSON: every table

```json
{
  "schemaVersion": 1,
  "exportedAt": "2026-11-17T01:41:00.000Z",
  "tables": {
    "projects": [{ "id": 1, "name": "Website redesign", "colorKey": "blue", "iconKey": "globe", "description": null, "deadline": null, "archivedAt": null, "createdAt": 1774260000000, "sortOrder": 0 }],
    "repeat_rules": [],
    "tasks": [],
    "subtasks": [],
    "tags": [],
    "task_tags": [],
    "links": [],
    "focus_sessions": [],
    "preferences": [{ "key": "userName", "value": "Alex" }]
  }
}
```

- **`schemaVersion`** is the database's schema version, so a later version of the app knows how to read the file. **`exportedAt`** is in UTC.
- **`tables`** holds one array per database table, in an order that loads without breaking a reference: parents come before the rows that point to them.
- **Each row** has the table's columns, named as in `lib/core/db/tables.dart`:
  - Timestamps (`createdAt`, `completedAt`, `startedAt`, …) are **milliseconds since the Unix epoch**, UTC.
  - Due dates, deadlines and repeat end dates are calendar days stored as **UTC midnight**, in the same milliseconds.
  - Enums are stored by name (`"open"`, `"medium"`, `"focus"`).
  - Booleans are `true` or `false`.
- **Preferences** are key-value pairs, with each value stored as text.
- **Partial exports** still load: repeat rules, subtasks, links and tag links come only with their tasks. A focus session whose task isn't exported keeps its time, with `taskId` set to `null`.

With everything included and All time, the JSON is an exact copy of the database. `test/features/data_transfer/data/drift_export_source_test.dart` loads it into an empty database and checks that every table matches. Restore uses the same loader.

## Backups (v1.1)

Backups (S42) are this JSON with everything included, named `ctrltask-backup-YYYY-MM-DD-HHmm.json` in local time. Only the newest **Keep** are kept, and other files in the folder are left alone. Each backup is written to `….json.tmp` and then renamed, so an interrupted backup never sits under a backup's name.

Restore checks the whole file before touching anything:
- **The file:** valid JSON with a `schemaVersion` and every table, and every row of the right type.
- **Older versions:** a file from an older version is upgraded step by step to the current schema. A newer version, or one older than any upgrade, is refused.

It then replaces everything in one transaction. If any row can't go in, for example a broken reference, nothing changes.
