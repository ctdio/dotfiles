#!/usr/bin/env bun

/**
 * Lightweight stream parser for Claude Code JSON output
 * Extracts and displays text_delta content incrementally
 * Handles content block boundaries for proper spacing
 * Logs tool calls with their inputs
 */

const decoder = new TextDecoder();
let lastBlockIndex = -1;
let lastBlockType = '';
let currentToolName = '';
let currentToolInput = '';

for await (const chunk of Bun.stdin.stream()) {
  const lines = decoder.decode(chunk).split('\n');

  for (const line of lines) {
    if (!line.trim()) continue;

    try {
      const json = JSON.parse(line);

      // Handle content block start - track block changes
      if (json.type === 'stream_event' && json.event?.type === 'content_block_start') {
        const blockType = json.event?.content_block?.type;
        const blockIndex = json.event?.index;

        // Log tool use blocks (name only, input comes via deltas)
        if (blockType === 'tool_use') {
          currentToolName = json.event?.content_block?.name || '';
          currentToolInput = '';
          process.stdout.write(`\n\x1b[2m[${currentToolName}`);
        }
        // Add spacing between different content blocks
        else if (lastBlockIndex !== -1 && blockIndex !== lastBlockIndex) {
          process.stdout.write('\n');
        }

        lastBlockIndex = blockIndex;
        lastBlockType = blockType;
      }
      // Accumulate input_json_delta for tool inputs
      else if (json.type === 'stream_event' &&
          json.event?.type === 'content_block_delta' &&
          json.event?.delta?.type === 'input_json_delta') {
        currentToolInput += json.event.delta.partial_json || '';
      }
      // Extract text from content_block_delta events
      else if (json.type === 'stream_event' &&
          json.event?.type === 'content_block_delta' &&
          json.event?.delta?.type === 'text_delta') {
        process.stdout.write(json.event.delta.text);
      }
      // Handle content block stop
      else if (json.type === 'stream_event' && json.event?.type === 'content_block_stop') {
        // Print accumulated tool input and close bracket
        if (lastBlockType === 'tool_use' && currentToolInput) {
          try {
            const parsed = JSON.parse(currentToolInput);
            const inputStr = JSON.stringify(parsed, null, 2)
              .split('\n')
              .map(l => '  ' + l)
              .join('\n');
            process.stdout.write(`\n${inputStr}`);
          } catch {
            // If parsing fails, just show raw input
            process.stdout.write(` ${currentToolInput}`);
          }
          process.stdout.write(']\x1b[0m\n');
          currentToolName = '';
          currentToolInput = '';
        }
        // Add newline after text blocks end
        else if (lastBlockType === 'text') {
          process.stdout.write('\n');
        }
      }
      // Show final result message if present
      else if (json.type === 'result' && json.subtype === 'success') {
        // Result already shown via deltas, just ensure final newline
        process.stdout.write('\n');
      }
      // Handle errors
      else if (json.type === 'result' && json.is_error) {
        console.error('\nError:', json.result);
      }
    } catch (e) {
      // Skip malformed JSON lines
      continue;
    }
  }
}
