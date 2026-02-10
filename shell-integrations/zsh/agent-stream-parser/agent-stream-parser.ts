#!/usr/bin/env bun

/**
 * Pretty stream parser for Claude Code JSON output
 * Renders tool outputs with specialized formatting
 */

// ANSI color codes
const c = {
  reset: "\x1b[0m",
  dim: "\x1b[2m",
  bold: "\x1b[1m",
  green: "\x1b[32m",
  red: "\x1b[31m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  cyan: "\x1b[36m",
  magenta: "\x1b[35m",
  gray: "\x1b[90m",
  bgGreen: "\x1b[42m",
  bgRed: "\x1b[41m",
  bgCyan: "\x1b[46m",
  bgMagenta: "\x1b[45m",
  black: "\x1b[30m",
  // Subtle diff backgrounds (256-color)
  bgDiffAdd: "\x1b[48;5;22m", // dark green bg
  bgDiffRemove: "\x1b[48;5;52m", // dark red bg
};

// Box drawing characters
const box = {
  v: "┃",
  h: "─",
  tl: "┌",
  tr: "┐",
  bl: "└",
  br: "┘",
  arrow: "→",
  updown: "↕",
};

// State
let lastBlockIndex = -1;
let lastBlockType = "";
let currentToolName = "";
let currentToolInput = "";
let currentToolUseId = "";
let lastToolName = "";
let lastToolCategory = ""; // Track category for spacing between groups

// Tool categories for visual grouping
type ToolCategory =
  | "meta"
  | "file"
  | "search"
  | "command"
  | "web"
  | "agent"
  | "other";

function getToolCategory(toolName: string): ToolCategory {
  switch (toolName) {
    case "TodoWrite":
    case "TaskCreate":
    case "TaskUpdate":
    case "TaskList":
    case "TaskGet":
      return "meta";
    case "Read":
    case "Edit":
    case "MultiEdit":
    case "Write":
    case "NotebookEdit":
      return "file";
    case "Glob":
    case "Grep":
      return "search";
    case "Bash":
      return "command";
    case "WebSearch":
    case "WebFetch":
      return "web";
    case "Task":
    case "Skill":
      return "agent";
    default:
      return "other";
  }
}

// Subagent state - track active subagents by their parent_tool_use_id
interface SubagentState {
  agentType: string; // e.g., "Explore"
  description: string; // e.g., "Explore ralph script"
  promptPreview: string; // First line of prompt
  toolCount: number;
}
const activeSubagents = new Map<string, SubagentState>();
let lastOutputAgent: string | null = null; // Track which agent last produced output

function registerSubagent(
  toolUseId: string,
  agentType: string,
  description: string,
  promptPreview: string,
): void {
  activeSubagents.set(toolUseId, {
    agentType,
    description,
    promptPreview,
    toolCount: 0,
  });
}

function unregisterSubagent(parentId: string): void {
  activeSubagents.delete(parentId);
}

function isInSubagent(parentId: string | null): boolean {
  return parentId !== null && activeSubagents.has(parentId);
}

// Print agent name header if switching to a different agent
function printAgentContextSwitch(parentId: string | null): void {
  if (parentId === lastOutputAgent) return;
  lastOutputAgent = parentId;
  lastToolCategory = ""; // Reset category when switching agents
  // Reset todo state for new agent context
  lastTodoState = new Map();
  isFirstTodoUpdate = true;

  if (parentId) {
    const state = activeSubagents.get(parentId);
    if (state) {
      // Color block for agent type, then description
      const typeBlock = `${c.bgCyan}${c.black} ${state.agentType} ${c.reset}`;
      const desc = state.description ? ` ${state.description}` : "";
      process.stdout.write(`\n${typeBlock}${desc}\n`);
    }
  }
}

// Indent for subagent content
const subagentIndent = `${c.dim}│${c.reset} `;

// Cache terminal width (invalidated on SIGWINCH)
let cachedTermWidth: number | null = null;
process.on("SIGWINCH", () => {
  cachedTermWidth = null;
});

// Get terminal width for line wrapping
function getTermWidth(): number {
  if (cachedTermWidth !== null) return cachedTermWidth;

  // Try stdout columns first (works when stdout is a TTY)
  if (process.stdout.columns) {
    cachedTermWidth = process.stdout.columns;
    return cachedTermWidth;
  }

  // Check COLUMNS env var (set by shell, survives piping)
  const envCols = parseInt(process.env.COLUMNS || "", 10);
  if (!isNaN(envCols) && envCols > 0) {
    cachedTermWidth = envCols;
    return cachedTermWidth;
  }

  // Fallback: use tput cols (works when piped, reads from /dev/tty)
  try {
    const result = Bun.spawnSync(["tput", "cols"]);
    const cols = parseInt(result.stdout.toString().trim(), 10);
    if (!isNaN(cols) && cols > 0) {
      cachedTermWidth = cols;
      return cachedTermWidth;
    }
  } catch {
    // tput not available or failed
  }

  cachedTermWidth = 80;
  return cachedTermWidth;
}

// Wrap text to fit within terminal width, accounting for prefix
function wrapLine(line: string, maxWidth: number, prefixLen: number): string[] {
  const contentWidth = maxWidth - prefixLen;
  if (contentWidth <= 20) return [line]; // Too narrow, don't wrap

  const result: string[] = [];
  let remaining = line;

  while (remaining.length > contentWidth) {
    // Find a good break point (space, punctuation)
    let breakAt = remaining.lastIndexOf(" ", contentWidth);
    if (breakAt <= contentWidth * 0.5) {
      // No good break point, break at max width
      breakAt = contentWidth;
    }
    result.push(remaining.slice(0, breakAt));
    remaining = remaining.slice(breakAt).trimStart();
  }

  if (remaining) {
    result.push(remaining);
  }

  return result;
}

// Todo state tracking for incremental display
interface TodoItem {
  id?: string;
  content: string;
  status: string;
}
let lastTodoState: Map<string, string> = new Map(); // content -> status (using content as key since id may not exist)
let isFirstTodoUpdate = true;

// Main formatters
function formatTodoStatus(status: string): { icon: string; color: string } {
  switch (status) {
    case "completed":
      return { icon: "✓", color: c.green };
    case "in_progress":
      return { icon: "◉", color: c.yellow };
    case "pending":
    default:
      return { icon: "○", color: c.gray };
  }
}

function formatTodoWrite(input: { todos: Array<TodoItem> }): string {
  const todos = input.todos || [];
  const lines: string[] = [];

  // Calculate progress
  const completed = todos.filter((t) => t.status === "completed").length;
  const total = todos.length;
  const inProgress = todos.find((t) => t.status === "in_progress");

  // First update: show full list
  if (isFirstTodoUpdate) {
    isFirstTodoUpdate = false;
    lines.push(
      `${c.bold}${c.cyan}Todos${c.reset} ${c.dim}(${completed}/${total})${c.reset}`,
    );
    for (const todo of todos) {
      const { icon, color } = formatTodoStatus(todo.status);
      lines.push(`${color}${icon}${c.reset} ${todo.content}`);
    }
    // Save state (use content as key since id may not exist)
    lastTodoState = new Map(todos.map((t) => [t.content, t.status]));
    return "\n" + lines.join("\n") + "\n";
  }

  // Incremental update: find what just changed
  const newlyCompleted: TodoItem[] = [];
  const newlyStarted: TodoItem[] = [];

  for (const todo of todos) {
    const prevStatus = lastTodoState.get(todo.content);
    if (todo.status === "completed" && prevStatus !== "completed") {
      newlyCompleted.push(todo);
    }
    if (todo.status === "in_progress" && prevStatus !== "in_progress") {
      newlyStarted.push(todo);
    }
  }

  // Update saved state
  lastTodoState = new Map(todos.map((t) => [t.content, t.status]));

  // Only show if something changed
  if (newlyCompleted.length === 0 && newlyStarted.length === 0) {
    return "";
  }

  // Compact display: progress + only the changes
  lines.push(
    `${c.bold}${c.cyan}Todos${c.reset} ${c.dim}(${completed}/${total})${c.reset}`,
  );

  for (const todo of newlyCompleted) {
    lines.push(`${c.green}✓${c.reset} ${todo.content}`);
  }

  for (const todo of newlyStarted) {
    lines.push(`${c.yellow}◉${c.reset} ${todo.content}`);
  }

  return "\n" + lines.join("\n") + "\n";
}

function formatTaskCreate(input: {
  subject: string;
  description?: string;
  activeForm?: string;
}): string {
  const lines: string[] = [];
  lines.push(`${c.cyan}${c.bold}+ Task${c.reset}`);
  lines.push(`${c.gray}○${c.reset} ${input.subject}`);
  if (input.description) {
    const desc =
      input.description.length > 60
        ? input.description.slice(0, 57) + "..."
        : input.description;
    lines.push(`  ${c.dim}${desc}${c.reset}`);
  }
  return "\n" + lines.join("\n") + "\n";
}

function formatTaskUpdate(input: {
  taskId: string;
  status?: string;
  subject?: string;
}): string {
  const lines: string[] = [];
  const statusText = input.status || "update";
  const { icon, color } = formatTodoStatus(input.status || "pending");

  lines.push(
    `${c.cyan}${c.bold}↻ Task #${input.taskId}${c.reset} ${c.dim}→ ${statusText}${c.reset}`,
  );
  if (input.subject) {
    lines.push(`${color}${icon}${c.reset} ${input.subject}`);
  }
  return "\n" + lines.join("\n") + "\n";
}

function formatTaskList(): string {
  return `\n${c.blue}TaskList${c.reset}\n`;
}

// Helper to check if we should add spacing before this tool
function shouldAddCategorySpacing(toolName: string): boolean {
  const category = getToolCategory(toolName);
  if (lastToolCategory === "" || lastToolCategory === category) {
    return false;
  }
  return true;
}

async function formatEdit(
  input: { file_path: string; old_string: string; new_string: string },
  width?: number,
): Promise<string> {
  const { file_path, old_string, new_string } = input;

  // Create temp files for diff
  const timestamp = Date.now();
  const oldFile = `/tmp/cc-old-${timestamp}`;
  const newFile = `/tmp/cc-new-${timestamp}`;

  await Bun.write(oldFile, old_string);
  await Bun.write(newFile, new_string);

  try {
    // Generate unified diff with proper labels
    const diffProc = Bun.spawn(
      [
        "diff",
        "-u",
        "--label",
        `a/${file_path}`,
        "--label",
        `b/${file_path}`,
        oldFile,
        newFile,
      ],
      { stdout: "pipe", stderr: "pipe" },
    );

    const diffOutput = await new Response(diffProc.stdout).text();
    await diffProc.exited;

    // If no changes, return minimal output
    if (!diffOutput.trim()) {
      return `\n${c.cyan}${file_path}${c.reset}  ${c.dim}(no changes)${c.reset}\n`;
    }

    // Pipe to skim print for syntax highlighting
    const effectiveWidth = width ?? getTermWidth();
    const skimProc = Bun.spawn(
      ["skim", "print", "-w", String(effectiveWidth)],
      {
        stdin: new Response(diffOutput).body,
        stdout: "pipe",
        stderr: "pipe",
      },
    );

    const skimOutput = await new Response(skimProc.stdout).text();
    await skimProc.exited;

    return "\n" + skimOutput;
  } finally {
    // Clean up temp files
    try {
      await Bun.$`rm -f ${oldFile} ${newFile}`.quiet();
    } catch {
      // Ignore cleanup errors
    }
  }
}

function formatWrite(input: { file_path: string; content: string }): string {
  const contentLines = input.content.split("\n");
  const lineCount = contentLines.length;

  const lines: string[] = [];
  lines.push(
    `\n${c.cyan}${input.file_path}${c.reset}  ${c.green}+${lineCount} lines${c.reset} ${c.dim}(new file)${c.reset}`,
  );

  // Show preview (first 10 lines)
  const preview = contentLines.slice(0, 10);
  lines.push(`${c.dim}${box.v}       preview${c.reset}`);

  for (let i = 0; i < preview.length; i++) {
    const lineNum = String(i + 1).padStart(3);
    lines.push(
      `${c.dim}${box.v}${c.reset} ${c.green}${lineNum}+${c.reset} ${preview[i]}`,
    );
  }

  if (contentLines.length > 10) {
    lines.push(
      `${c.dim}${box.v}     ... ${contentLines.length - 10} more lines${c.reset}`,
    );
  }

  return lines.join("\n") + "\n";
}

// Track pending Task info for registration
interface PendingTask {
  agentType: string;
  description: string;
  promptPreview: string;
}
const pendingTasks = new Map<string, PendingTask>();

function formatTask(input: {
  prompt: string;
  subagent_type: string;
  description?: string;
}): string {
  const agentType = input.subagent_type || "agent";
  const desc = input.description || "";
  const termWidth = getTermWidth();
  const pipePrefix = "│ ";

  // Get first 10 non-empty lines of prompt
  const promptLines = input.prompt
    .split("\n")
    .filter((l) => l.trim())
    .slice(0, 10);

  // Color block for agent type
  const typeBlock = `${c.bgCyan}${c.black} ${agentType} ${c.reset}`;
  const descPart = desc ? ` ${desc}` : "";

  // Build output with pipe prefix for prompt lines, wrapped to terminal width
  const lines = [
    `\n${c.magenta}Task${c.reset} ${c.dim}${box.arrow}${c.reset} ${typeBlock}${descPart}`,
  ];
  for (const line of promptLines) {
    const wrapped = wrapLine(line, termWidth, pipePrefix.length);
    for (const wrappedLine of wrapped) {
      lines.push(`${c.dim}${pipePrefix}${wrappedLine}${c.reset}`);
    }
  }

  return lines.join("\n") + "\n";
}

function formatRead(input: {
  file_path: string;
  offset?: number;
  limit?: number;
}): string {
  const parts = [
    `${c.blue}Read${c.reset} ${c.cyan}${input.file_path}${c.reset}`,
  ];

  if (input.offset || input.limit) {
    const range = [];
    if (input.offset) range.push(`offset: ${input.offset}`);
    if (input.limit) range.push(`limit: ${input.limit}`);
    parts.push(`${c.dim}(${range.join(", ")})${c.reset}`);
  }

  return "\n" + parts.join(" ") + "\n";
}

function formatBash(input: { command: string; description?: string }): string {
  const lines: string[] = [];
  const desc = input.description
    ? ` ${c.dim}# ${input.description}${c.reset}`
    : "";

  lines.push(`\n${c.yellow}$ ${c.reset}${input.command}${desc}`);

  return lines.join("\n") + "\n";
}

function formatGlob(input: { pattern: string; path?: string }): string {
  const path = input.path || ".";
  return `\n${c.blue}Glob${c.reset} ${c.cyan}${input.pattern}${c.reset} ${c.dim}in ${path}${c.reset}\n`;
}

function formatGrep(input: {
  pattern: string;
  path?: string;
  glob?: string;
}): string {
  const parts = [
    `${c.blue}Grep${c.reset} ${c.yellow}/${input.pattern}/${c.reset}`,
  ];
  if (input.path)
    parts.push(`${c.dim}in${c.reset} ${c.cyan}${input.path}${c.reset}`);
  if (input.glob) parts.push(`${c.dim}glob:${c.reset} ${input.glob}`);
  return "\n" + parts.join(" ") + "\n";
}

function formatWebSearch(input: { query: string }): string {
  return `\n${c.blue}Search${c.reset} ${c.yellow}"${input.query}"${c.reset}\n`;
}

function formatWebFetch(input: { url: string; prompt?: string }): string {
  const lines: string[] = [];
  lines.push(`\n${c.blue}Fetch${c.reset} ${c.cyan}${input.url}${c.reset}`);
  if (input.prompt) {
    const truncated =
      input.prompt.length > 60
        ? input.prompt.slice(0, 57) + "..."
        : input.prompt;
    lines.push(`${c.dim}${box.v} ${truncated}${c.reset}`);
  }
  return lines.join("\n") + "\n";
}

function formatAskUserQuestion(input: {
  questions: Array<{ question: string; header?: string }>;
}): string {
  const lines: string[] = [];
  lines.push(`\n${c.yellow}${c.bold}Question${c.reset}`);
  for (const q of input.questions || []) {
    if (q.header) lines.push(`   ${c.dim}[${q.header}]${c.reset}`);
    lines.push(`   ${q.question}`);
  }
  return lines.join("\n") + "\n";
}

function formatSkill(input: { skill: string; args?: string }): string {
  const args = input.args ? ` ${c.dim}${input.args}${c.reset}` : "";
  return `\n${c.magenta}/${input.skill}${c.reset}${args}\n`;
}

function formatCompactTool(toolName: string, input: unknown): string | null {
  try {
    const parsed = typeof input === "string" ? JSON.parse(input) : input;

    switch (toolName) {
      case "Read":
        return `Read ${parsed.file_path?.split("/").pop() || "..."}`;
      case "Glob":
        return `Glob ${parsed.pattern}`;
      case "Grep":
        return `Grep /${parsed.pattern}/`;
      case "Edit":
      case "MultiEdit":
        return `Edit ${parsed.file_path?.split("/").pop() || "..."}`;
      case "Write":
        return `Write ${parsed.file_path?.split("/").pop() || "..."}`;
      case "Bash":
        const cmd = parsed.command?.slice(0, 40) || "";
        return `$ ${cmd}${parsed.command?.length > 40 ? "..." : ""}`;
      case "WebSearch":
        return `Search "${parsed.query?.slice(0, 30)}..."`;
      case "WebFetch":
        return `Fetch ${parsed.url?.slice(0, 40)}...`;
      default:
        return `${toolName}`;
    }
  } catch {
    return toolName;
  }
}

function formatSubagentCompletion(
  result: {
    agentId?: string;
    totalDurationMs?: number;
    totalToolUseCount?: number;
    content?: Array<{ type: string; text?: string }>;
  },
  _parentId: string | null,
): string {
  const lines: string[] = [];
  const termWidth = getTermWidth();
  // subagentIndent has ANSI codes, so use raw prefix length for wrapping
  const prefixLen = 2; // "│ "

  // Find the text content (summary) and indent it with wrapping
  const textContent = result.content?.find((c) => c.type === "text" && c.text);
  if (textContent?.text) {
    for (const line of textContent.text.split("\n")) {
      if (!line.trim()) {
        lines.push(subagentIndent);
        continue;
      }
      const wrapped = wrapLine(line, termWidth, prefixLen);
      for (const wrappedLine of wrapped) {
        lines.push(subagentIndent + wrappedLine);
      }
    }
  }

  // Show completion stats
  const stats: string[] = [];
  if (result.totalToolUseCount) {
    stats.push(`${result.totalToolUseCount} tools`);
  }
  if (result.totalDurationMs) {
    const secs = (result.totalDurationMs / 1000).toFixed(1);
    stats.push(`${secs}s`);
  }

  if (stats.length > 0) {
    lines.push(
      `${subagentIndent}${c.green}✓${c.reset} ${c.dim}${stats.join(" · ")}${c.reset}`,
    );
  }

  return lines.join("\n") + "\n";
}

function formatCodexCommandStart(command: string): string {
  return formatBash({ command });
}

function formatCodexCommandOutput(
  output: string,
  exitCode: number | null,
): string {
  const trimmedOutput = output.trimEnd();
  if (!trimmedOutput && (exitCode === null || exitCode === 0)) {
    return "";
  }

  const lines: string[] = [];
  if (trimmedOutput) {
    for (const line of trimmedOutput.split("\n")) {
      lines.push(`${c.dim}${box.v}${c.reset} ${line}`);
    }
  }

  if (exitCode !== null && exitCode !== 0) {
    lines.push(`${c.red}${box.v}${c.reset} ${c.red}exit ${exitCode}${c.reset}`);
  }

  return `\n${lines.join("\n")}\n`;
}

function formatCodexReasoning(text: string): string {
  return `\n${c.dim}${text}${c.reset}\n`;
}

async function formatToolOutput(
  toolName: string,
  input: unknown,
  width?: number,
): Promise<string> {
  try {
    const parsed = typeof input === "string" ? JSON.parse(input) : input;

    switch (toolName) {
      case "TodoWrite":
        return formatTodoWrite(parsed);
      case "TaskCreate":
        return formatTaskCreate(parsed);
      case "TaskUpdate":
        return formatTaskUpdate(parsed);
      case "TaskList":
        return formatTaskList();
      case "Edit":
        return await formatEdit(parsed, width);
      case "MultiEdit":
        // MultiEdit has an array of edits
        if (parsed.edits && Array.isArray(parsed.edits)) {
          const results = await Promise.all(
            parsed.edits.map(
              (edit: {
                file_path: string;
                old_string: string;
                new_string: string;
              }) => formatEdit(edit, width),
            ),
          );
          return results.join("");
        }
        return await formatEdit(parsed, width);
      case "Write":
        return formatWrite(parsed);
      case "Task":
        return formatTask(parsed);
      case "Read":
        return formatRead(parsed);
      case "Bash":
        return formatBash(parsed);
      case "Glob":
        return formatGlob(parsed);
      case "Grep":
        return formatGrep(parsed);
      case "WebSearch":
        return formatWebSearch(parsed);
      case "WebFetch":
        return formatWebFetch(parsed);
      case "AskUserQuestion":
        return formatAskUserQuestion(parsed);
      case "Skill":
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
    const parsed = typeof input === "string" ? JSON.parse(input) : input;
    const inputStr = JSON.stringify(parsed, null, 2)
      .split("\n")
      .map((l) => `${c.dim}${box.v}${c.reset} ${l}`)
      .join("\n");
    lines.push(inputStr);
  } catch {
    lines.push(`${c.dim}${box.v}${c.reset} ${input}`);
  }

  return lines.join("\n") + "\n";
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

async function formatApplyPatch(patchText: string): Promise<string> {
  // Convert OpenCode patch format to unified diff for skim rendering
  // OpenCode format:
  // *** Begin Patch
  // *** Add File: /path/to/file
  // +new content
  // *** Update File: /path/to/file
  // @@
  // -old line
  // +new line
  // *** End Patch

  const lines = patchText.split("\n");
  const diffLines: string[] = [];
  let currentFile = "";
  let isAddFile = false;

  for (const line of lines) {
    if (
      line.startsWith("*** Begin Patch") ||
      line.startsWith("*** End Patch")
    ) {
      continue;
    }

    if (line.startsWith("*** Add File: ")) {
      currentFile = line.replace("*** Add File: ", "");
      isAddFile = true;
      diffLines.push(`--- /dev/null`);
      diffLines.push(`+++ b/${currentFile}`);
      diffLines.push("@@ -0,0 +1 @@");
    } else if (line.startsWith("*** Update File: ")) {
      currentFile = line.replace("*** Update File: ", "");
      isAddFile = false;
      diffLines.push(`--- a/${currentFile}`);
      diffLines.push(`+++ b/${currentFile}`);
    } else if (line.startsWith("*** Delete File: ")) {
      currentFile = line.replace("*** Delete File: ", "");
      diffLines.push(`--- a/${currentFile}`);
      diffLines.push(`+++ /dev/null`);
    } else if (line === "@@") {
      diffLines.push("@@ -1 +1 @@");
    } else if (line.startsWith("+") || line.startsWith("-") || line === " ") {
      diffLines.push(line);
    } else if (line.trim() && !isAddFile) {
      // Context line without prefix
      diffLines.push(" " + line);
    } else if (line.trim() && isAddFile) {
      // For add file, lines without + prefix are still additions
      if (!line.startsWith("+")) {
        diffLines.push("+" + line);
      } else {
        diffLines.push(line);
      }
    }
  }

  const diffOutput = diffLines.join("\n");

  if (!diffOutput.trim()) {
    return `\n${c.cyan}patch${c.reset} ${c.dim}(empty)${c.reset}\n`;
  }

  try {
    // Pipe through skim for syntax highlighting
    const effectiveWidth = getTermWidth();
    const skimProc = Bun.spawn(
      ["skim", "print", "-w", String(effectiveWidth)],
      {
        stdin: new Response(diffOutput).body,
        stdout: "pipe",
        stderr: "pipe",
      },
    );

    const skimOutput = await new Response(skimProc.stdout).text();
    await skimProc.exited;

    return "\n" + skimOutput;
  } catch {
    // Fallback: show raw diff with colors
    const coloredLines = diffLines.map((line) => {
      if (line.startsWith("+")) return `${c.green}${line}${c.reset}`;
      if (line.startsWith("-")) return `${c.red}${line}${c.reset}`;
      if (line.startsWith("@@")) return `${c.cyan}${line}${c.reset}`;
      return line;
    });
    return "\n" + coloredLines.join("\n") + "\n";
  }
}

// Patterns to skip in tool results (redundant confirmations)
const skipResultPatterns = [
  /has been (updated|created|modified|written) successfully/i,
  /^The file .* has been/,
  /Todos have been modified/i,
];

function formatToolResult(text: string): string {
  // Filter out lines matching skip patterns
  const lines = text.split("\n").filter((line) => {
    const trimmed = line.trim();
    if (!trimmed) return true; // keep empty lines
    return !skipResultPatterns.some((p) => p.test(trimmed));
  });

  // If all lines were filtered, return empty
  if (lines.every((l) => !l.trim())) return "";

  const maxLines = 10;

  if (lines.length > maxLines) {
    const shown = lines.slice(0, maxLines);
    return (
      shown.map((l) => `${c.dim}${box.v}${c.reset} ${l}`).join("\n") +
      `\n${c.dim}${box.v} ... ${lines.length - maxLines} more lines${c.reset}\n`
    );
  }

  return lines.map((l) => `${c.dim}${box.v}${c.reset} ${l}`).join("\n") + "\n";
}

function handleOpenCodeEvent(json: Record<string, unknown>): boolean {
  const type = json.type;
  if (typeof type !== "string") return false;

  // OpenCode events: step_start, step_finish, text, tool_use
  if (!["step_start", "step_finish", "text", "tool_use"].includes(type)) {
    return false;
  }

  const part = isRecord(json.part) ? json.part : null;
  if (!part) return true;

  if (type === "text" && typeof part.text === "string") {
    process.stdout.write(part.text + "\n");
    return true;
  }

  if (type === "tool_use") {
    const tool = typeof part.tool === "string" ? part.tool : "";
    const state = isRecord(part.state) ? part.state : null;
    const input = isRecord(state?.input) ? state.input : {};
    const output = typeof state?.output === "string" ? state.output : "";
    const metadata = isRecord(state?.metadata) ? state.metadata : {};
    const exitCode = typeof metadata.exit === "number" ? metadata.exit : null;

    // Format based on tool type
    if (tool === "bash") {
      const cmd = typeof input.command === "string" ? input.command : "";
      const desc =
        typeof input.description === "string" ? input.description : "";
      process.stdout.write(formatBash({ command: cmd, description: desc }));
      if (output.trim()) {
        process.stdout.write(formatCodexCommandOutput(output, exitCode));
      }
    } else if (tool === "read") {
      const filePath =
        typeof input.file_path === "string" ? input.file_path : "";
      process.stdout.write(formatRead({ file_path: filePath }));
    } else if (tool === "write") {
      const filePath =
        typeof input.file_path === "string" ? input.file_path : "";
      const content = typeof input.content === "string" ? input.content : "";
      process.stdout.write(formatWrite({ file_path: filePath, content }));
    } else if (tool === "glob") {
      const pattern = typeof input.pattern === "string" ? input.pattern : "";
      const path = typeof input.path === "string" ? input.path : undefined;
      process.stdout.write(formatGlob({ pattern, path }));
    } else if (tool === "grep") {
      const pattern = typeof input.pattern === "string" ? input.pattern : "";
      const path = typeof input.path === "string" ? input.path : undefined;
      const glob = typeof input.glob === "string" ? input.glob : undefined;
      process.stdout.write(formatGrep({ pattern, path, glob }));
    } else if (tool === "edit") {
      const filePath =
        typeof input.file_path === "string" ? input.file_path : "";
      const oldStr =
        typeof input.old_string === "string" ? input.old_string : "";
      const newStr =
        typeof input.new_string === "string" ? input.new_string : "";
      formatEdit({
        file_path: filePath,
        old_string: oldStr,
        new_string: newStr,
      }).then((out) => {
        process.stdout.write(out);
      });
    } else if (tool === "apply_patch") {
      const patchText =
        typeof input.patchText === "string" ? input.patchText : "";
      formatApplyPatch(patchText).then((out) => {
        process.stdout.write(out);
      });
    } else if (tool === "todowrite") {
      const todos = Array.isArray(input.todos) ? input.todos : [];
      process.stdout.write(formatTodoWrite({ todos }));
    } else {
      // Generic tool
      process.stdout.write(formatGenericTool(tool, input));
      if (output.trim()) {
        process.stdout.write(formatToolResult(output));
      }
    }
    return true;
  }

  if (type === "step_finish") {
    const reason = typeof part.reason === "string" ? part.reason : "";
    if (reason === "stop") {
      process.stdout.write("\n");
    }
    return true;
  }

  return true;
}

function handleCodexEvent(json: Record<string, unknown>): boolean {
  const type = json.type;
  if (typeof type !== "string") return false;
  if (
    !type.startsWith("thread.") &&
    !type.startsWith("turn.") &&
    !type.startsWith("item.")
  ) {
    return false;
  }

  if (type === "item.started") {
    const item = isRecord(json.item) ? json.item : null;
    if (
      item &&
      typeof item.type === "string" &&
      item.type === "command_execution" &&
      typeof item.command === "string"
    ) {
      process.stdout.write(formatCodexCommandStart(item.command));
    }
    return true;
  }

  if (type === "item.completed") {
    const item = isRecord(json.item) ? json.item : null;
    if (!item || typeof item.type !== "string") return true;

    if (item.type === "command_execution" && typeof item.command === "string") {
      const output =
        typeof item.aggregated_output === "string"
          ? item.aggregated_output
          : "";
      const exitCode =
        typeof item.exit_code === "number" ? item.exit_code : null;
      process.stdout.write(formatCodexCommandOutput(output, exitCode));
      return true;
    }

    if (item.type === "agent_message" && typeof item.text === "string") {
      process.stdout.write(`${item.text}\n`);
      return true;
    }

    if (item.type === "reasoning" && typeof item.text === "string") {
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
  const lines = decoder.decode(chunk).split("\n");

  for (const line of lines) {
    if (!line.trim()) continue;

    try {
      const json = JSON.parse(line);

      if (handleOpenCodeEvent(json)) {
        continue;
      }

      if (handleCodexEvent(json)) {
        continue;
      }

      // Handle content block start
      if (
        json.type === "stream_event" &&
        json.event?.type === "content_block_start"
      ) {
        const blockType = json.event?.content_block?.type;
        const blockIndex = json.event?.index;
        const parentId = json.parent_tool_use_id;

        // Register subagent if we see a new parent_tool_use_id
        if (parentId && !activeSubagents.has(parentId)) {
          const pending = pendingTasks.get(parentId);
          if (pending) {
            pendingTasks.delete(parentId);
            registerSubagent(
              parentId,
              pending.agentType,
              pending.description,
              pending.promptPreview,
            );
          } else {
            registerSubagent(parentId, "agent", "", "");
          }
        }

        if (blockType === "tool_use") {
          currentToolName = json.event?.content_block?.name || "";
          currentToolUseId = json.event?.content_block?.id || "";
          currentToolInput = "";
        } else if (lastBlockIndex !== -1 && blockIndex !== lastBlockIndex) {
          process.stdout.write("\n");
        }

        lastBlockIndex = blockIndex;
        lastBlockType = blockType;
      }
      // Accumulate tool input
      else if (
        json.type === "stream_event" &&
        json.event?.type === "content_block_delta" &&
        json.event?.delta?.type === "input_json_delta"
      ) {
        currentToolInput += json.event.delta.partial_json || "";
      }
      // Stream text output
      else if (
        json.type === "stream_event" &&
        json.event?.type === "content_block_delta" &&
        json.event?.delta?.type === "text_delta"
      ) {
        const parentId = json.parent_tool_use_id;
        // Skip subagent text streaming - we show the final summary instead
        if (!isInSubagent(parentId)) {
          process.stdout.write(json.event.delta.text);
        }
      }
      // Handle content block stop - format tool output
      else if (
        json.type === "stream_event" &&
        json.event?.type === "content_block_stop"
      ) {
        const parentId = json.parent_tool_use_id;

        if (lastBlockType === "tool_use" && currentToolInput) {
          // Register Task tool calls - store info for when we see child events
          if (currentToolName === "Task" && currentToolUseId) {
            try {
              const taskInput = JSON.parse(currentToolInput);
              pendingTasks.set(currentToolUseId, {
                agentType: taskInput.subagent_type || "agent",
                description: taskInput.description || "",
                promptPreview:
                  taskInput.prompt?.split("\n")[0]?.slice(0, 80) || "",
              });
            } catch {
              pendingTasks.set(currentToolUseId, {
                agentType: "agent",
                description: "",
                promptPreview: "",
              });
            }
          }

          // Check if we need spacing between tool categories
          const currentCategory = getToolCategory(currentToolName);
          const needsCategorySpacing =
            lastToolCategory !== "" && lastToolCategory !== currentCategory;

          // In subagent context - show tool indented under agent
          if (isInSubagent(parentId)) {
            printAgentContextSwitch(parentId);
            const state = activeSubagents.get(parentId);
            if (state) {
              state.toolCount++;
            }
            // Add spacing between categories
            if (needsCategorySpacing) {
              process.stdout.write(subagentIndent + "\n");
            }
            // Indent the output, strip leading newline since header provides separation
            // Reduce width by 2 for subagent indent ("│ ")
            const subagentWidth = getTermWidth() - 2;
            const output = (
              await formatToolOutput(
                currentToolName,
                currentToolInput,
                subagentWidth,
              )
            ).replace(/^\n/, "");
            process.stdout.write(
              output
                .split("\n")
                .map((l) => (l ? subagentIndent + l : l))
                .join("\n"),
            );
          } else {
            // Add spacing between categories for main agent
            if (needsCategorySpacing) {
              process.stdout.write("\n");
            }
            process.stdout.write(
              await formatToolOutput(currentToolName, currentToolInput),
            );
          }
          currentToolUseId = "";
          lastToolName = currentToolName;
          lastToolCategory = currentCategory;
          currentToolName = "";
          currentToolInput = "";
        } else if (lastBlockType === "text") {
          if (!isInSubagent(parentId)) {
            process.stdout.write("\n");
          }
        }
      }
      // Handle tool results (sub-agent output, bash output, etc.)
      else if (json.type === "user" && json.message?.content) {
        const parentId = json.parent_tool_use_id;

        // Check if this is a subagent completing (Task tool_use_result with agentId)
        if (json.tool_use_result?.agentId) {
          // Find which subagent this completes by looking at the tool_use_id in content
          const toolUseId = json.message?.content?.find(
            (b: { type: string; tool_use_id?: string }) =>
              b.type === "tool_result",
          )?.tool_use_id;

          // Show context header if switching to this agent
          if (toolUseId) {
            printAgentContextSwitch(toolUseId);
          }

          process.stdout.write(
            formatSubagentCompletion(json.tool_use_result, toolUseId),
          );

          if (toolUseId) {
            unregisterSubagent(toolUseId);
            lastOutputAgent = null; // Reset so next output shows header
          }
          lastToolName = "";
          continue;
        }

        // Register subagent if we see a new parent_tool_use_id
        if (parentId && !activeSubagents.has(parentId)) {
          const pending = pendingTasks.get(parentId);
          if (pending) {
            pendingTasks.delete(parentId);
            registerSubagent(
              parentId,
              pending.agentType,
              pending.description,
              pending.promptPreview,
            );
          } else {
            registerSubagent(parentId, "agent", "", "");
          }
        }

        // Skip results for tools where we already show formatted output
        const skipResultTools = [
          "Edit",
          "MultiEdit",
          "Write",
          "TodoWrite",
          "TaskCreate",
          "TaskUpdate",
          "TaskList",
          "TaskGet",
        ];
        if (skipResultTools.includes(lastToolName)) {
          lastToolName = "";
          continue;
        }

        // In subagent context - skip tool results (we show the final summary)
        if (isInSubagent(parentId)) {
          lastToolName = "";
          continue;
        }

        for (const block of json.message.content) {
          if (block.type === "tool_result") {
            const content = block.content;
            const text =
              typeof content === "string"
                ? content
                : Array.isArray(content)
                  ? content
                      .filter((i: { type: string }) => i.type === "text")
                      .map((i: { text: string }) => i.text)
                      .join("\n")
                  : "";

            if (text.trim()) {
              process.stdout.write(formatToolResult(text));
            }
          }
        }
        lastToolName = "";
      }
      // Handle subagent assistant messages (tool calls from subagents)
      else if (json.type === "assistant" && json.parent_tool_use_id) {
        const parentId = json.parent_tool_use_id;

        // Register subagent if not already tracked
        if (!activeSubagents.has(parentId)) {
          const pending = pendingTasks.get(parentId);
          if (pending) {
            pendingTasks.delete(parentId);
            registerSubagent(
              parentId,
              pending.agentType,
              pending.description,
              pending.promptPreview,
            );
          } else {
            registerSubagent(parentId, "agent", "", "");
          }
        }

        // Print context header if switching agents
        printAgentContextSwitch(parentId);

        // Show tool calls in normal format (like main agent)
        const toolUses =
          json.message?.content?.filter(
            (b: { type: string }) => b.type === "tool_use",
          ) || [];

        for (const tool of toolUses) {
          const state = activeSubagents.get(parentId);
          if (state) {
            state.toolCount++;
          }
          // Show tool call indented, strip leading newline
          // Reduce width by 2 for subagent indent ("│ ")
          const subagentWidth = getTermWidth() - 2;
          const output = (
            await formatToolOutput(tool.name, tool.input, subagentWidth)
          ).replace(/^\n/, "");
          process.stdout.write(
            output
              .split("\n")
              .map((l) => (l ? subagentIndent + l : l))
              .join("\n"),
          );
        }
      }
      // Final result
      else if (json.type === "result" && json.subtype === "success") {
        process.stdout.write("\n");
      }
      // Errors
      else if (json.type === "result" && json.is_error) {
        console.error(`\n${c.red}Error:${c.reset}`, json.result);
      }
    } catch {
      continue;
    }
  }
}
