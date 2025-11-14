#!/usr/bin/env bun
import { describe, test, expect, beforeEach } from 'bun:test';
import { spawn } from 'child_process';
import path from 'path';

const HOOK_PATH = path.join(__dirname, 'validate-bash');

interface HookResult {
  exitCode: number;
  stdout: string;
  stderr: string;
}

function runHook(command: string): Promise<HookResult> {
  return new Promise((resolve) => {
    const payload = JSON.stringify({
      session_id: 'test-session',
      transcript_path: '/tmp/test.jsonl',
      cwd: '/tmp',
      permission_mode: 'default',
      hook_event_name: 'PreToolUse',
      tool_name: 'Bash',
      tool_input: { command },
    });

    const proc = spawn(HOOK_PATH, [], {
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';

    proc.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    proc.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    proc.on('close', (code) => {
      resolve({
        exitCode: code ?? 0,
        stdout,
        stderr,
      });
    });

    proc.stdin.write(payload);
    proc.stdin.end();
  });
}

describe('Bash Command Validation Hook', () => {
  describe('Terraform commands', () => {
    test('blocks terraform commands', async () => {
      const result = await runHook('terraform apply');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('Terraform commands are blocked');
    });

    test('blocks terraform with different subcommands', async () => {
      const commands = [
        'terraform plan',
        'terraform destroy',
        'terraform init',
        'TERRAFORM apply',
      ];

      for (const cmd of commands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(2);
        expect(result.stderr).toContain('Terraform');
      }
    });
  });

  describe('Prisma commands', () => {
    test('blocks prisma db push', async () => {
      const result = await runHook('prisma db push');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('prisma db push');
    });

    test('blocks prisma deploy', async () => {
      const result = await runHook('prisma deploy');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('prisma deploy');
    });

    test('blocks prisma migrate deploy', async () => {
      const result = await runHook('prisma migrate deploy');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('prisma migrate deploy');
    });

    test('blocks prisma migrate dev without --create-only', async () => {
      const result = await runHook('prisma migrate dev');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('--create-only');
    });

    test('blocks prisma migrate dev with --name but no --create-only', async () => {
      const result = await runHook('prisma migrate dev --name add-users');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('--create-only');
    });

    test('allows prisma migrate dev with --create-only', async () => {
      const result = await runHook('prisma migrate dev --create-only');
      expect(result.exitCode).toBe(0);
      expect(result.stderr).toBe('');
    });

    test('allows prisma migrate dev with --create-only and --name', async () => {
      const result = await runHook(
        'prisma migrate dev --create-only --name add-users'
      );
      expect(result.exitCode).toBe(0);
      expect(result.stderr).toBe('');
    });

    test('allows prisma migrate dev with --name and --create-only', async () => {
      const result = await runHook(
        'prisma migrate dev --name add-users --create-only'
      );
      expect(result.exitCode).toBe(0);
      expect(result.stderr).toBe('');
    });

    test('allows safe prisma commands', async () => {
      const safeCommands = [
        'prisma generate',
        'prisma studio',
        'prisma format',
        'npx prisma migrate dev --create-only',
      ];

      for (const cmd of safeCommands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(0);
      }
    });
  });

  describe('Deploy commands', () => {
    test('blocks npm run deploy', async () => {
      const result = await runHook('npm run deploy');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('Deploy scripts are blocked');
    });

    test('blocks various package manager deploy commands', async () => {
      const commands = [
        'yarn run deploy',
        'pnpm run deploy',
        'bun run deploy',
      ];

      for (const cmd of commands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(2);
      }
    });

    test('blocks production deployment patterns', async () => {
      const commands = [
        'deploy --env production',
        'git push deploy prod',
        './scripts/deploy production',
      ];

      for (const cmd of commands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(2);
      }
    });

    test('allows non-deploy scripts', async () => {
      const safeCommands = [
        'npm run build',
        'npm run test',
        'yarn dev',
        'pnpm install',
      ];

      for (const cmd of safeCommands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(0);
      }
    });
  });

  describe('Destructive filesystem operations', () => {
    test('blocks rm -rf /', async () => {
      const result = await runHook('rm -rf /');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('Recursive delete from root');
    });

    test('blocks rm -rf ~', async () => {
      const result = await runHook('rm -rf ~');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('home directory');
    });

    test('blocks rm -rf with wildcards', async () => {
      const result = await runHook('rm -rf *');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('wildcard');
    });

    test('allows safe rm commands', async () => {
      const safeCommands = [
        'rm file.txt',
        'rm -f build/output.js',
        'rm -rf node_modules',
        'rm -rf /tmp/my-temp-dir',
      ];

      for (const cmd of safeCommands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(0);
      }
    });

    test('blocks mv to /dev/null', async () => {
      const result = await runHook('mv important-file.txt /dev/null');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('/dev/null');
    });

    test('blocks dd commands', async () => {
      const result = await runHook('dd if=/dev/zero of=/dev/sda');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('dd');
    });

    test('blocks mkfs', async () => {
      const result = await runHook('mkfs.ext4 /dev/sda1');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('formatting');
    });

    test('blocks disk partitioning tools', async () => {
      const commands = ['fdisk /dev/sda', 'parted /dev/sda', 'gpart show'];

      for (const cmd of commands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(2);
      }
    });
  });

  describe('Dangerous system commands', () => {
    test('blocks fork bomb', async () => {
      const result = await runHook(':(){ :|:& };:');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('Fork bomb');
    });

    test('blocks chmod 777', async () => {
      const result = await runHook('chmod 777 file.txt');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('777');
    });

    test('blocks chmod -R 777', async () => {
      const result = await runHook('chmod -R 777 /var/www');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('777');
    });

    test('blocks chown -R from root', async () => {
      const result = await runHook('chown -R user:group /');
      expect(result.exitCode).toBe(2);
      expect(result.stderr).toContain('chown');
    });

    test('allows safe chmod commands', async () => {
      const safeCommands = [
        'chmod +x script.sh',
        'chmod 755 file.txt',
        'chmod -R 644 docs/',
      ];

      for (const cmd of safeCommands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(0);
      }
    });
  });

  describe('Non-Bash tools', () => {
    test('allows non-Bash tools to pass through', async () => {
      const payload = JSON.stringify({
        session_id: 'test-session',
        transcript_path: '/tmp/test.jsonl',
        cwd: '/tmp',
        permission_mode: 'default',
        hook_event_name: 'PreToolUse',
        tool_name: 'Read',
        tool_input: { file_path: '/etc/passwd' },
      });

      const proc = spawn(HOOK_PATH, [], {
        stdio: ['pipe', 'pipe', 'pipe'],
      });

      let stderr = '';
      proc.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      const exitCodePromise = new Promise<number>((resolve) => {
        proc.on('close', (code) => resolve(code ?? 0));
      });

      proc.stdin.write(payload);
      proc.stdin.end();

      const exitCode = await exitCodePromise;
      expect(exitCode).toBe(0);
      expect(stderr).toBe('');
    });
  });

  describe('Safe commands', () => {
    test('allows common safe commands', async () => {
      const safeCommands = [
        'ls -la',
        'git status',
        'npm install',
        'echo "hello world"',
        'cat file.txt',
        'grep "pattern" file.txt',
        'find . -name "*.ts"',
        'docker ps',
        'kubectl get pods',
        'make build',
        'cargo test',
        'go run main.go',
      ];

      for (const cmd of safeCommands) {
        const result = await runHook(cmd);
        expect(result.exitCode).toBe(0);
        expect(result.stderr).toBe('');
      }
    });
  });
});
