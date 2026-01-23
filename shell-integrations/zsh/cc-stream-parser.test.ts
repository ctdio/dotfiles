import { describe, expect, test } from 'bun:test';

// Import the formatters by re-exporting them
// Since the main file runs immediately, we need to extract the formatters

// ANSI color codes (duplicated for testing)
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
};

const box = {
  v: '┃',
  arrow: '→',
  updown: '↕',
};

// Re-implement formatters for testing (or we could refactor to export them)
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

function formatTaskCreate(input: { subject: string; description?: string }): string {
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

function formatEdit(input: { file_path: string; old_string: string; new_string: string }): string {
  const oldLines = input.old_string.split('\n');
  const newLines = input.new_string.split('\n');

  const added = newLines.filter((l, i) => !oldLines.includes(l) || oldLines[i] !== l).length;
  const removed = oldLines.filter((l, i) => !newLines.includes(l) || newLines[i] !== l).length;

  const stats = [];
  if (added > 0) stats.push(`${c.green}+${added}${c.reset}`);
  if (removed > 0) stats.push(`${c.red}-${removed}${c.reset}`);

  const lines: string[] = [];
  lines.push(`\n${c.cyan}${input.file_path}${c.reset}  ${stats.join(' ')}`);
  lines.push(`${c.dim}${box.v}       ${box.updown} ${oldLines.length} ${box.arrow} ${newLines.length}${c.reset}`);

  let oldIdx = 0;
  let newIdx = 0;

  while (oldIdx < oldLines.length || newIdx < newLines.length) {
    const oldLine = oldLines[oldIdx];
    const newLine = newLines[newIdx];

    if (oldLine === newLine) {
      const lineNum = String(newIdx + 1).padStart(3);
      lines.push(`${c.dim}${box.v}${c.reset} ${c.dim}${lineNum}${c.reset}  ${oldLine}`);
      oldIdx++;
      newIdx++;
    } else {
      if (oldIdx < oldLines.length && (newIdx >= newLines.length || oldLine !== newLines[newIdx])) {
        const lineNum = String(oldIdx + 1).padStart(3);
        lines.push(`${c.dim}${box.v}${c.reset} ${c.red}${lineNum}-${c.reset} ${c.red}${oldLine}${c.reset}`);
        oldIdx++;
      }
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

  const promptLines = input.prompt.split('\n').slice(0, 5);
  lines.push(`${c.dim}${box.v} prompt:${c.reset}`);

  for (const line of promptLines) {
    const truncated = line.length > 80 ? line.slice(0, 77) + '...' : line;
    lines.push(`${c.dim}${box.v}${c.reset}   ${truncated}`);
  }

  if (input.prompt.split('\n').length > 5) {
    lines.push(`${c.dim}${box.v}   ... (truncated)${c.reset}`);
  }

  return lines.join('\n') + '\n';
}

function formatBash(input: { command: string; description?: string }): string {
  const desc = input.description ? ` ${c.dim}# ${input.description}${c.reset}` : '';
  return `\n${c.yellow}$ ${c.reset}${input.command}${desc}\n`;
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

// Strip ANSI codes for easier assertions
function stripAnsi(str: string): string {
  return str.replace(/\x1b\[[0-9;]*m/g, '');
}

// Tests
describe('formatTodoWrite', () => {
  test('renders empty todo list', () => {
    const result = formatTodoWrite({ todos: [] });
    expect(stripAnsi(result)).toContain('Todos');
  });

  test('renders completed todo with checkmark', () => {
    const result = formatTodoWrite({
      todos: [{ id: '1', content: 'Done task', status: 'completed' }]
    });
    expect(stripAnsi(result)).toContain('✓');
    expect(stripAnsi(result)).toContain('Done task');
  });

  test('renders in_progress todo with filled circle', () => {
    const result = formatTodoWrite({
      todos: [{ id: '1', content: 'Working on it', status: 'in_progress' }]
    });
    expect(stripAnsi(result)).toContain('◉');
    expect(stripAnsi(result)).toContain('Working on it');
  });

  test('renders pending todo with empty circle', () => {
    const result = formatTodoWrite({
      todos: [{ id: '1', content: 'Not started', status: 'pending' }]
    });
    expect(stripAnsi(result)).toContain('○');
    expect(stripAnsi(result)).toContain('Not started');
  });

  test('renders multiple todos with different statuses', () => {
    const result = formatTodoWrite({
      todos: [
        { id: '1', content: 'Task 1', status: 'completed' },
        { id: '2', content: 'Task 2', status: 'in_progress' },
        { id: '3', content: 'Task 3', status: 'pending' },
      ]
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('✓');
    expect(stripped).toContain('◉');
    expect(stripped).toContain('○');
  });
});

describe('formatTaskCreate', () => {
  test('renders task with subject', () => {
    const result = formatTaskCreate({ subject: 'Implement feature X' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('+ Task');
    expect(stripped).toContain('Implement feature X');
  });

  test('renders task with description', () => {
    const result = formatTaskCreate({
      subject: 'Feature X',
      description: 'This is a detailed description'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('Feature X');
    expect(stripped).toContain('This is a detailed description');
  });

  test('truncates long descriptions', () => {
    const longDesc = 'A'.repeat(100);
    const result = formatTaskCreate({ subject: 'Task', description: longDesc });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('...');
    expect(stripped.length).toBeLessThan(longDesc.length + 50);
  });
});

describe('formatTaskUpdate', () => {
  test('renders task update with status', () => {
    const result = formatTaskUpdate({ taskId: '1', status: 'completed' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('Task #1');
    expect(stripped).toContain('completed');
  });

  test('renders completed status with checkmark', () => {
    const result = formatTaskUpdate({
      taskId: '1',
      status: 'completed',
      subject: 'Done task'
    });
    expect(stripAnsi(result)).toContain('✓');
  });
});

describe('formatEdit', () => {
  test('shows file path', () => {
    const result = formatEdit({
      file_path: '/path/to/file.ts',
      old_string: 'old',
      new_string: 'new'
    });
    expect(stripAnsi(result)).toContain('/path/to/file.ts');
  });

  test('shows added line count', () => {
    const result = formatEdit({
      file_path: 'file.ts',
      old_string: 'line1',
      new_string: 'line1\nline2'
    });
    expect(stripAnsi(result)).toContain('+');
  });

  test('shows removed line count', () => {
    const result = formatEdit({
      file_path: 'file.ts',
      old_string: 'line1\nline2',
      new_string: 'line1'
    });
    expect(stripAnsi(result)).toContain('-');
  });

  test('shows line numbers', () => {
    const result = formatEdit({
      file_path: 'file.ts',
      old_string: 'old line',
      new_string: 'new line'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toMatch(/\d+-/); // removed line number
    expect(stripped).toMatch(/\d+\+/); // added line number
  });

  test('handles multi-line edits', () => {
    const result = formatEdit({
      file_path: 'file.ts',
      old_string: 'line1\nline2\nline3',
      new_string: 'line1\nmodified\nline3'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('line1');
    expect(stripped).toContain('modified');
    expect(stripped).toContain('line3');
  });

  test('includes ANSI colors for additions', () => {
    const result = formatEdit({
      file_path: 'file.ts',
      old_string: 'old',
      new_string: 'new'
    });
    expect(result).toContain(c.green);
  });

  test('includes ANSI colors for removals', () => {
    const result = formatEdit({
      file_path: 'file.ts',
      old_string: 'old',
      new_string: 'new'
    });
    expect(result).toContain(c.red);
  });
});

describe('formatWrite', () => {
  test('shows file path and line count', () => {
    const result = formatWrite({
      file_path: '/new/file.ts',
      content: 'line1\nline2\nline3'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('/new/file.ts');
    expect(stripped).toContain('+3 lines');
    expect(stripped).toContain('(new file)');
  });

  test('shows preview of first 10 lines', () => {
    const content = Array.from({ length: 5 }, (_, i) => `line ${i + 1}`).join('\n');
    const result = formatWrite({ file_path: 'file.ts', content });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('line 1');
    expect(stripped).toContain('line 5');
  });

  test('truncates files longer than 10 lines', () => {
    const content = Array.from({ length: 20 }, (_, i) => `line ${i + 1}`).join('\n');
    const result = formatWrite({ file_path: 'file.ts', content });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('... 10 more lines');
  });
});

describe('formatTask', () => {
  test('shows agent type and description', () => {
    const result = formatTask({
      prompt: 'Do something',
      subagent_type: 'Explore',
      description: 'Find files'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('Task');
    expect(stripped).toContain('Explore');
    expect(stripped).toContain('Find files');
  });

  test('shows prompt preview', () => {
    const result = formatTask({
      prompt: 'Search for files matching pattern',
      subagent_type: 'Explore'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('prompt:');
    expect(stripped).toContain('Search for files');
  });

  test('truncates long prompts', () => {
    const longPrompt = Array.from({ length: 10 }, (_, i) => `Line ${i + 1}`).join('\n');
    const result = formatTask({
      prompt: longPrompt,
      subagent_type: 'agent'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('(truncated)');
  });

  test('truncates long lines', () => {
    const longLine = 'A'.repeat(100);
    const result = formatTask({
      prompt: longLine,
      subagent_type: 'agent'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('...');
  });
});

describe('formatBash', () => {
  test('shows command with dollar sign prompt', () => {
    const result = formatBash({ command: 'git status' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('$ git status');
  });

  test('shows description as comment', () => {
    const result = formatBash({
      command: 'git status',
      description: 'Check repo status'
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('# Check repo status');
  });
});

describe('formatRead', () => {
  test('shows file path', () => {
    const result = formatRead({ file_path: '/path/to/file.ts' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('Read');
    expect(stripped).toContain('/path/to/file.ts');
  });

  test('shows offset and limit if provided', () => {
    const result = formatRead({
      file_path: 'file.ts',
      offset: 10,
      limit: 50
    });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('offset: 10');
    expect(stripped).toContain('limit: 50');
  });
});

describe('formatGlob', () => {
  test('shows pattern and default path', () => {
    const result = formatGlob({ pattern: '**/*.ts' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('Glob');
    expect(stripped).toContain('**/*.ts');
    expect(stripped).toContain('in .');
  });

  test('shows custom path', () => {
    const result = formatGlob({ pattern: '*.js', path: '/src' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('in /src');
  });
});

describe('formatGrep', () => {
  test('shows pattern with slashes', () => {
    const result = formatGrep({ pattern: 'TODO' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('Grep');
    expect(stripped).toContain('/TODO/');
  });

  test('shows path if provided', () => {
    const result = formatGrep({ pattern: 'error', path: '/src' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('in');
    expect(stripped).toContain('/src');
  });

  test('shows glob if provided', () => {
    const result = formatGrep({ pattern: 'test', glob: '*.spec.ts' });
    const stripped = stripAnsi(result);
    expect(stripped).toContain('glob:');
    expect(stripped).toContain('*.spec.ts');
  });
});

describe('ANSI color codes', () => {
  test('Edit output contains color codes', () => {
    const result = formatEdit({
      file_path: 'file.ts',
      old_string: 'old',
      new_string: 'new'
    });
    expect(result).toContain('\x1b['); // Contains ANSI escape
  });

  test('TodoWrite output contains color codes', () => {
    const result = formatTodoWrite({
      todos: [{ id: '1', content: 'Task', status: 'completed' }]
    });
    expect(result).toContain('\x1b[');
  });
});
