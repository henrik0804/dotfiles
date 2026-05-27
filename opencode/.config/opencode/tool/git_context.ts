import { tool } from "@opencode-ai/plugin"
import { execSync } from "node:child_process"

function run(cmd: string) {
  return execSync(cmd, { encoding: "utf8" }).trim()
}

export const summary = tool({
  description: "Returns git status plus the latest commits in a structured form.",
  args: {
    commitCount: tool.schema
      .number()
      .int()
      .min(1)
      .max(20)
      .optional()
      .default(5)
      .describe("Number of recent commits to include in the summary")
  },
  async execute({ commitCount }) {
    let status: string | null = null
    let statusError: string | null = null
    let commits: Array<{ hash: string; message: string }> = []
    let commitsError: string | null = null

    try {
      status = run("git status --short")
    } catch (error) {
      statusError = (error as Error).message
    }

    try {
      const log = run(`git log -${commitCount} --oneline`)
      commits = log
        .split("\n")
        .filter(Boolean)
        .map((line: string) => {
          const [hash, ...messageParts] = line.trim().split(" ")
          return { hash, message: messageParts.join(" ") }
        })
    } catch (error) {
      commitsError = (error as Error).message
    }

    if (status === null && statusError === null) {
      statusError = "git status output is empty"
    }
    if (commits.length === 0 && commitsError === null) {
      commitsError = "No commits found in git log"
    }

    const statusSection = statusError
      ? `### Git Status\n**Error**: ${statusError}`
      : `### Git Status\n\`\`\`\n${status || "(clean)"}\n\`\`\``

    const commitsSection = commitsError
      ? `### Recent Commits\n**Error**: ${commitsError}`
      : `### Recent Commits (${commits.length})\n${commits.map((c) => `- \`${c.hash}\` ${c.message}`).join("\n")}`

    return `## Git Context Summary

${statusSection}

${commitsSection}`
  }
})

export const deepDiff = tool({
  description: "Provides detailed git diffs for selected paths or the entire working tree.",
  args: {
    paths: tool.schema
      .array(tool.schema.string())
      .optional()
      .describe("File paths to diff; omit to diff the whole working tree."),
    context: tool.schema
      .number()
      .int()
      .min(0)
      .max(20)
      .optional()
      .default(5)
      .describe("Number of context lines in the diff")
  },
  async execute({ paths, context }) {
    const target = paths && paths.length > 0 ? paths.map((p) => `"${p}"`).join(" ") : ""
    let diff: string | null = null
    let diffError: string | null = null

    try {
      diff = run(`git diff --unified=${context}${target ? ` ${target}` : ""}`)
    } catch (error) {
      diffError = (error as Error).message
    }

    if ((diff === null || diff.length === 0) && diffError === null) {
      diffError = "Diff output is empty (no changes detected)"
    }

    const pathsInfo = paths && paths.length > 0 ? paths.join(", ") : "entire working tree"

    if (diffError) {
      return `## Git Deep Diff

**Paths**: ${pathsInfo}
**Context Lines**: ${context}

**Error**: ${diffError}`
    }

    return `## Git Deep Diff

**Paths**: ${pathsInfo}
**Context Lines**: ${context}

\`\`\`diff
${diff}
\`\`\``
  }
})
