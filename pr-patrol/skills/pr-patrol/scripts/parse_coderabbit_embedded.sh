#!/usr/bin/env bash
#
# parse_coderabbit_embedded.sh
# Extract embedded comments from CodeRabbit walkthrough issue comments
#
# Usage: parse_coderabbit_embedded.sh <issue_comments_json_file>
#
# CodeRabbit embeds certain comments in the walkthrough due to GitHub API
# limitations (cannot post inline comments outside diff range).
#
# Sections we extract:
#   - ♻️ Duplicate comments (N) - issues from previous reviews
#   - 🔇 Additional comments (N) - comments outside diff range
#   - 🧹 Nitpick comments - minor style suggestions
#
# Output: JSON array of extracted embedded comments with file/line/description

set -euo pipefail

INPUT_FILE="${1:-/dev/stdin}"

# Read all CodeRabbit issue comments
jq -r '
  # Function to extract section content
  def extract_section($marker; $end_marker):
    . as $body |
    if ($body | test($marker; "i")) then
      ($body | split($marker) | .[1:] | join($marker)) as $after_marker |
      if $end_marker != "" then
        ($after_marker | split($end_marker) | .[0])
      else
        $after_marker
      end
    else
      ""
    end;

  # Function to parse file entries from a section
  # Format: <details><summary>file.ts (N)</summary>...<blockquote>...</blockquote></details>
  def parse_file_entries:
    [
      scan("<details>\\s*<summary>([^<]+?)\\s*\\((\\d+)\\)</summary>.*?<blockquote>([\\s\\S]*?)</blockquote>\\s*</details>") |
      {
        file: .[0],
        count: (.[1] | tonumber),
        content: .[2]
      }
    ];

  # Function to extract individual issues from blockquote content
  # Format: `filename:line`: **title**\n\ndescription
  def parse_issues_from_content:
    [
      scan("`([^`]+)`:\\s*\\*\\*([^*]+)\\*\\*\\s*\\n\\n([^`]+?)(?=\\n\\n`|$)") |
      {
        location: .[0],
        title: .[1],
        description: (.[2] | gsub("\\n+$"; ""))
      }
    ];

  # Function to split location into file:line
  def parse_location:
    if test(":") then
      split(":") | {file: .[0], line: (.[1] | tonumber? // null)}
    else
      {file: ., line: null}
    end;

  # Process each CodeRabbit issue comment
  [
    .[] |
    select(.user.login == "coderabbitai[bot]" or .user.login == "coderabbitai") |
    select(.body | test("walkthrough_start|Walkthrough"; "i")) |
    .id as $comment_id |
    .body as $body |

    # Extract Duplicate comments section
    (
      if ($body | test("♻️ Duplicate comments"; "i")) then
        ($body | extract_section("♻️ Duplicate comments"; "📜 Review details|🔇 Additional|</details>\\s*\\n\\s*---")) |
        parse_file_entries |
        .[] |
        {
          source_comment_id: $comment_id,
          section_type: "duplicate",
          file: .file,
          issues: (.content | parse_issues_from_content)
        }
      else
        empty
      end
    ),

    # Extract Additional comments (outside diff range)
    (
      if ($body | test("🔇 Additional comments"; "i")) then
        ($body | extract_section("🔇 Additional comments"; "📜 Review details|♻️ Duplicate|</details>\\s*\\n\\s*---")) |
        parse_file_entries |
        .[] |
        {
          source_comment_id: $comment_id,
          section_type: "outside_diff",
          file: .file,
          issues: (.content | parse_issues_from_content)
        }
      else
        empty
      end
    ),

    # Extract Nitpick comments if embedded
    (
      if ($body | test("🧹 Nitpick"; "i")) then
        ($body | extract_section("🧹 Nitpick"; "📜 Review details|♻️ Duplicate|🔇 Additional|</details>\\s*\\n\\s*---")) |
        parse_file_entries |
        .[] |
        {
          source_comment_id: $comment_id,
          section_type: "nitpick",
          file: .file,
          issues: (.content | parse_issues_from_content)
        }
      else
        empty
      end
    )
  ] |

  # Flatten issues and add metadata
  [
    .[] |
    .source_comment_id as $cid |
    .section_type as $stype |
    .file as $file |
    .issues[] |
    {
      id: "embedded-\($cid)-\($stype)-\(.location | gsub("[^a-zA-Z0-9]"; "-"))",
      source_comment_id: $cid,
      section_type: $stype,
      file: $file,
      location: .location,
      title: .title,
      description: .description,
      severity: (
        if $stype == "duplicate" then "high"
        elif $stype == "outside_diff" then "medium"
        elif $stype == "nitpick" then "low"
        else "medium"
        end
      ),
      bot: "coderabbitai[bot]",
      is_embedded: true
    }
  ] |

  # Output summary and comments
  {
    total_embedded: length,
    by_type: (group_by(.section_type) | map({key: .[0].section_type, value: length}) | from_entries),
    comments: .
  }
' "$INPUT_FILE"
