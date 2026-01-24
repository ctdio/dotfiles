#!/usr/bin/env bun

/**
 * Pretty stream parser for Claude Code JSON output
 * Renders tool outputs with specialized formatting
 */

// ANSI color codes
const c = {
  reset: '\x1b[0m',
  dim: '\x1b[2m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m',
  gray: '\x1b[90m',
  bgGreen: '\x1b[42m',
  bgRed: '\x1b[41m',
};

// Box drawing characters
const box = {
  v: '┃',
  h: '─',
  tl: '┌',
  tr: '┐',
  bl: '└',
  br: '┘',
  arrow: '→',
  updown: '↕',
};

// State
let lastBlockIndex = -1;
let lastBlockType = '';
let currentToolName = '';
let currentToolInput = '';
let lastToolName = '';

// Main formatters
function formatTodoStatus(status: string): { icon: string; color: string } {
  switch (status) {
    case 'completed':
      return { icon: '✓', color: c.green };
    case 'in_progress':
      return { icon: '◉', color: c.yellow };
    case 'pending':
    default:
      return { icon: '○', color: c.gray };
  }
}

function formatTodoWrite(input: { todos: Array<{ id: string; content: string; status: string }> }): string {
  const lines: string[] = [];
  lines.push(`\n${c.bold}${c.cyan} Todos${c.reset}`);

  for (const todo of input.todos || []) {
    const { icon, color } = formatTodoStatus(todo.status);
    lines.push(` ${color}${icon}${c.reset}  ${todo.content}`);
  }

  return lines.join('\n') + '\n';
}

function formatTaskCreate(input: { subject: string; description?: string; activeForm?: string }): string {
  const lines: string[] = [];
  lines.push(`\n${c.cyan}${c.bold} + Task${c.reset}`);
  lines.push(` ${c.gray}○${c.reset}  ${input.subject}`);
  if (input.description) {
    const desc = input.description.length > 60 ? input.description.slice(0, 57) + '...' : input.description;
    lines.push(`     ${c.dim}${desc}${c.reset}`);
  }
  return lines.join('\n') + '\n';
}

function formatTaskUpdate(input: { taskId: string; status?: string; subject?: string }): string {
  const lines: string[] = [];
  const statusText = input.status || 'update';
  const { icon, color } = formatTodoStatus(input.status || 'pending');

  lines.push(`\n${c.cyan}${c.bold} ↻ Task #${input.taskId}${c.reset} ${c.dim}→ ${statusText}${c.reset}`);
  if (input.subject) {
    lines.push(` ${color}${icon}${c.reset}  ${input.subject}`);
  }
  return lines.join('\n') + '\n';
}

function formatTaskList(): string {
  return `\n${c.blue}TaskList${c.reset}\n`;
}

function formatEdit(input: { file_path: string; old_string: string; new_string: string }): string {
  const oldLines = input.old_string.split('\n');
  const newLines = input.new_string.split('\n');

  // Calculate stats
  const added = newLines.filter((l, i) => !oldLines.includes(l) || oldLines[i] !== l).length;
  const removed = oldLines.filter((l, i) => !newLines.includes(l) || newLines[i] !== l).length;

  const stats = [];
  if (added > 0) stats.push(`${c.green}+${added}${c.reset}`);
  if (removed > 0) stats.push(`${c.red}-${removed}${c.reset}`);

  const lines: string[] = [];
  lines.push(`\n${c.cyan}${input.file_path}${c.reset}  ${stats.join(' ')}`);
  lines.push(`${c.dim}${box.v}       ${box.updown} ${oldLines.length} ${box.arrow} ${newLines.length}${c.reset}`);

  // Create unified diff view
  let oldIdx = 0;
  let newIdx = 0;

  while (oldIdx < oldLines.length || newIdx < newLines.length) {
    const oldLine = oldLines[oldIdx];
    const newLine = newLines[newIdx];

    if (oldLine === newLine) {
      // Unchanged line - show as context
      const lineNum = String(newIdx + 1).padStart(3);
      lines.push(`${c.dim}${box.v}${c.reset} ${c.dim}${lineNum}${c.reset}  ${oldLine}`);
      oldIdx++;
      newIdx++;
    } else {
      // Show removed lines
      if (oldIdx < oldLines.length && (newIdx >= newLines.length || oldLine !== newLines[newIdx])) {
        const lineNum = String(oldIdx + 1).padStart(3);
        lines.push(`${c.dim}${box.v}${c.reset} ${c.red}${lineNum}-${c.reset} ${c.red}${oldLine}${c.reset}`);
        oldIdx++;
      }
      // Show added lines
      if (newIdx < newLines.length && (oldIdx >= oldLines.length || newLine !== oldLines[oldIdx - 1])) {
        const lineNum = String(newIdx + 1).padStart(3);
        lines.push(`${c.dim}${box.v}${c.reset} ${c.green}${lineNum}+${c.reset} ${c.green}${newLine}${c.reset}`);
        newIdx++;
      }
    }
  }

  return lines.join('\n') + '\n';
}

function formatWrite(input: { file_path: string; content: string }): string {
  const contentLines = input.content.split('\n');
  const lineCount = contentLines.length;

  const lines: string[] = [];
  lines.push(`\n${c.cyan}${input.file_path}${c.reset}  ${c.green}+${lineCount} lines${c.reset} ${c.dim}(new file)${c.reset}`);

  // Show preview (first 10 lines)
  const preview = contentLines.slice(0, 10);
  lines.push(`${c.dim}${box.v}       preview${c.reset}`);

  for (let i = 0; i < preview.length; i++) {
    const lineNum = String(i + 1).padStart(3);
    lines.push(`${c.dim}${box.v}${c.reset} ${c.green}${lineNum}+${c.reset} ${preview[i]}`);
  }

  if (contentLines.length > 10) {
    lines.push(`${c.dim}${box.v}     ... ${contentLines.length - 10} more lines${c.reset}`);
  }

  return lines.join('\n') + '\n';
}

function formatTask(input: { prompt: string; subagent_type: string; description?: string }): string {
  const lines: string[] = [];
  const agentName = input.subagent_type || 'agent';
  const desc = input.description || 'task';

  lines.push(`\n${c.magenta}${c.bold}Task${c.reset} ${c.dim}${box.arrow}${c.reset} ${c.cyan}${agentName}${c.reset} ${c.dim}(${desc})${c.reset}`);

  // Truncate prompt - show first 10 lines
  const promptLines = input.prompt.split('\n');
  const maxLines = 10;

  const previewLines = promptLines.slice(0, maxLines);

  if (previewLines.length > 0) {
    lines.push(`${c.dim}${box.tl}${box.h.repeat(60)}${c.reset}`);
    for (const line of previewLines) {
      lines.push(`${c.dim}${box.v}${c.reset} ${line}`);
    }
    if (promptLines.length > maxLines) {
      lines.push(`${c.dim}${box.v} ... (${promptLines.length} lines total)${c.reset}`);
    }
    lines.push(`${c.dim}${box.bl}${box.h.repeat(60)}${c.reset}`);
  }

  return lines.join('\n') + '\n';
}

function formatRead(input: { file_path: string; offset?: number; limit?: number }): string {
  const parts = [`${c.blue}Read${c.reset} ${c.cyan}${input.file_path}${c.reset}`];

  if (input.offset || input.limit) {
    const range = [];
    if (input.offset) range.push(`offset: ${input.offset}`);
    if (input.limit) range.push(`limit: ${input.limit}`);
    parts.push(`${c.dim}(${range.join(', ')})${c.reset}`);
  }

  return '\n' + parts.join(' ') + '\n';
}

function formatBash(input: { command: string; description?: string }): string {
  const lines: string[] = [];
  const desc = input.description ? ` ${c.dim}# ${input.description}${c.reset}` : '';

  lines.push(`\n${c.yellow}$ ${c.reset}${input.command}${desc}`);

  return lines.join('\n') + '\n';
}

function formatGlob(input: { pattern: string; path?: string }): string {
  const path = input.path || '.';
  return `\n${c.blue}Glob${c.reset} ${c.cyan}${input.pattern}${c.reset} ${c.dim}in ${path}${c.reset}\n`;
}

function formatGrep(input: { pattern: string; path?: string; glob?: string }): string {
  const parts = [`${c.blue}Grep${c.reset} ${c.yellow}/${input.pattern}/${c.reset}`];
  if (input.path) parts.push(`${c.dim}in${c.reset} ${c.cyan}${input.path}${c.reset}`);
  if (input.glob) parts.push(`${c.dim}glob:${c.reset} ${input.glob}`);
  return '\n' + parts.join(' ') + '\n';
}

function formatWebSearch(input: { query: string }): string {
  return `\n${c.blue}Search${c.reset} ${c.yellow}"${input.query}"${c.reset}\n`;
}

function formatWebFetch(input: { url: string; prompt?: string }): string {
  const lines: string[] = [];
  lines.push(`\n${c.blue}Fetch${c.reset} ${c.cyan}${input.url}${c.reset}`);
  if (input.prompt) {
    const truncated = input.prompt.length > 60 ? input.prompt.slice(0, 57) + '...' : input.prompt;
    lines.push(`${c.dim}${box.v} ${truncated}${c.reset}`);
  }
  return lines.join('\n') + '\n';
}

function formatAskUserQuestion(input: { questions: Array<{ question: string; header?: string }> }): string {
  const lines: string[] = [];
  lines.push(`\n${c.yellow}${c.bold}Question${c.reset}`);
  for (const q of input.questions || []) {
    if (q.header) lines.push(`   ${c.dim}[${q.header}]${c.reset}`);
    lines.push(`   ${q.question}`);
  }
  return lines.join('\n') + '\n';
}

function formatSkill(input: { skill: string; args?: string }): string {
  const args = input.args ? ` ${c.dim}${input.args}${c.reset}` : '';
  return `\n${c.magenta}/${input.skill}${c.reset}${args}\n`;
}

function formatCodexCommandStart(command: string): string {
  return formatBash({ command });
}

function formatCodexCommandOutput(output: string, exitCode: number | null): string {
  const trimmedOutput = output.trimEnd();
  if (!trimmedOutput && (exitCode === null || exitCode === 0)) {
    return '';
  }

  const lines: string[] = [];
  if (trimmedOutput) {
    for (const line of trimmedOutput.split('\n')) {
      lines.push(`${c.dim}${box.v}${c.reset} ${line}`);
    }
  }

  if (exitCode !== null && exitCode !== 0) {
    lines.push(`${c.red}${box.v}${c.reset} ${c.red}exit ${exitCode}${c.reset}`);
  }

  return `\n${lines.join('\n')}\n`;
}

function formatCodexReasoning(text: string): string {
  return `\n${c.dim}${text}${c.reset}\n`;
}

function formatToolOutput(toolName: string, input: unknown): string {
  try {
    const parsed = typeof input === 'string' ? JSON.parse(input) : input;

    switch (toolName) {
      case 'TodoWrite':
        return formatTodoWrite(parsed);
      case 'TaskCreate':
        return formatTaskCreate(parsed);
      case 'TaskUpdate':
        return formatTaskUpdate(parsed);
      case 'TaskList':
        return formatTaskList();
      case 'Edit':
        return formatEdit(parsed);
      case 'MultiEdit':
        // MultiEdit has an array of edits
        if (parsed.edits && Array.isArray(parsed.edits)) {
          return parsed.edits.map((edit: { file_path: string; old_string: string; new_string: string }) =>
            formatEdit(edit)
          ).join('');
        }
        return formatEdit(parsed);
      case 'Write':
        return formatWrite(parsed);
      case 'Task':
        return formatTask(parsed);
      case 'Read':
        return formatRead(parsed);
      case 'Bash':
        return formatBash(parsed);
      case 'Glob':
        return formatGlob(parsed);
      case 'Grep':
        return formatGrep(parsed);
      case 'WebSearch':
        return formatWebSearch(parsed);
      case 'WebFetch':
        return formatWebFetch(parsed);
      case 'AskUserQuestion':
        return formatAskUserQuestion(parsed);
      case 'Skill':
        return formatSkill(parsed);
      default:
        return formatGenericTool(toolName, parsed);
    }
  } catch {
    return formatGenericTool(toolName, input);
  }
}

function formatGenericTool(toolName: string, input: unknown): string {
  const lines: string[] = [];
  lines.push(`\n${c.dim}[${toolName}]${c.reset}`);

  try {
    const parsed = typeof input === 'string' ? JSON.parse(input) : input;
    const inputStr = JSON.stringify(parsed, null, 2)
      .split('\n')
      .map(l => `${c.dim}${box.v}${c.reset} ${l}`)
      .join('\n');
    lines.push(inputStr);
  } catch {
    lines.push(`${c.dim}${box.v}${c.reset} ${input}`);
  }

  return lines.join('\n') + '\n';
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

function formatToolResult(text: string): string {
  const lines = text.split('\n');
  const maxLines = 10;

  if (lines.length > maxLines) {
    const shown = lines.slice(0, maxLines);
    return shown.map(l => `${c.dim}${box.v}${c.reset} ${l}`).join('\n') +
      `\n${c.dim}${box.v} ... ${lines.length - maxLines} more lines${c.reset}\n`;
  }

  return lines.map(l => `${c.dim}${box.v}${c.reset} ${l}`).join('\n') + '\n';
}

function handleCodexEvent(json: Record<string, unknown>): boolean {
  const type = json.type;
  if (typeof type !== 'string') return false;
  if (!type.startsWith('thread.') && !type.startsWith('turn.') && !type.startsWith('item.')) {
    return false;
  }

  if (type === 'item.started') {
    const item = isRecord(json.item) ? json.item : null;
    if (item && typeof item.type === 'string' && item.type === 'command_execution' && typeof item.command === 'string') {
      process.stdout.write(formatCodexCommandStart(item.command));
    }
    return true;
  }

  if (type === 'item.completed') {
    const item = isRecord(json.item) ? json.item : null;
    if (!item || typeof item.type !== 'string') return true;

    if (item.type === 'command_execution' && typeof item.command === 'string') {
      const output = typeof item.aggregated_output === 'string' ? item.aggregated_output : '';
      const exitCode = typeof item.exit_code === 'number' ? item.exit_code : null;
      process.stdout.write(formatCodexCommandOutput(output, exitCode));
      return true;
    }

    if (item.type === 'agent_message' && typeof item.text === 'string') {
      process.stdout.write(`${item.text}\n`);
      return true;
    }

    if (item.type === 'reasoning' && typeof item.text === 'string') {
      process.stdout.write(formatCodexReasoning(item.text));
      return true;
    }

    process.stdout.write(formatGenericTool(item.type, item));
    return true;
  }

  return true;
}

// Main parsing loop
const decoder = new TextDecoder();

for await (const chunk of Bun.stdin.stream()) {
  const lines = decoder.decode(chunk).split('\n');

  for (const line of lines) {
    if (!line.trim()) continue;

    try {
      const json = JSON.parse(line);

      if (handleCodexEvent(json)) {
        continue;
      }

      // Handle content block start
      if (json.type === 'stream_event' && json.event?.type === 'content_block_start') {
        const blockType = json.event?.content_block?.type;
        const blockIndex = json.event?.index;

        if (blockType === 'tool_use') {
          currentToolName = json.event?.content_block?.name || '';
          currentToolInput = '';
        } else if (lastBlockIndex !== -1 && blockIndex !== lastBlockIndex) {
          process.stdout.write('\n');
        }

        lastBlockIndex = blockIndex;
        lastBlockType = blockType;
      }
      // Accumulate tool input
      else if (json.type === 'stream_event' &&
          json.event?.type === 'content_block_delta' &&
          json.event?.delta?.type === 'input_json_delta') {
        currentToolInput += json.event.delta.partial_json || '';
      }
      // Stream text output
      else if (json.type === 'stream_event' &&
          json.event?.type === 'content_block_delta' &&
          json.event?.delta?.type === 'text_delta') {
        process.stdout.write(json.event.delta.text);
      }
      // Handle content block stop - format tool output
      else if (json.type === 'stream_event' && json.event?.type === 'content_block_stop') {
        if (lastBlockType === 'tool_use' && currentToolInput) {
          process.stdout.write(formatToolOutput(currentToolName, currentToolInput));
          lastToolName = currentToolName;
          currentToolName = '';
          currentToolInput = '';
        } else if (lastBlockType === 'text') {
          process.stdout.write('\n');
        }
      }
      // Handle tool results (sub-agent output, bash output, etc.)
      else if (json.type === 'user' && json.message?.content) {
        // Skip results for Edit/Write - we already show the diff
        if (['Edit', 'MultiEdit', 'Write'].includes(lastToolName)) {
          lastToolName = '';
          continue;
        }

        for (const block of json.message.content) {
          if (block.type === 'tool_result') {
            const content = block.content;
            const text = typeof content === 'string'
              ? content
              : Array.isArray(content)
                ? content.filter((i: { type: string }) => i.type === 'text').map((i: { text: string }) => i.text).join('\n')
                : '';

            if (text.trim()) {
              process.stdout.write(formatToolResult(text));
            }
          }
        }
        lastToolName = '';
      }
      // Final result
      else if (json.type === 'result' && json.subtype === 'success') {
        process.stdout.write('\n');
      }
      // Errors
      else if (json.type === 'result' && json.is_error) {
        console.error(`\n${c.red}Error:${c.reset}`, json.result);
      }
    } catch {
      continue;
    }
  }
}
