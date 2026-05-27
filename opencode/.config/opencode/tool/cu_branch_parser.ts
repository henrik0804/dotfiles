import { tool } from "@opencode-ai/plugin"

const CU_PATTERN = /(CU)-([a-z0-9]+)/gi;

export default tool({
  description: "Extracts the ClickUp task ID from a branch name that follows the CU-123456 convention.",
  args: {
    branch: tool.schema
      .string()
      .describe("Full git branch name, e.g. feature/fix-email-CU-123456"),
    fallbackTaskId: tool.schema
      .string()
      .optional()
      .describe("Optional task identifier used when no CU ID is present in the branch")
  },
  async execute({ branch, fallbackTaskId }) {
    const matches: Array<{ raw: string; slug: string; taskId: string }> = []

    branch.replace(CU_PATTERN, (_, prefix: string, id: string) => {
      matches.push({
        raw: `${prefix}-${id}`,
        slug: `${prefix.toUpperCase()}-${id}`,
        taskId: id
      })
      return _
    })

    if (matches.length === 0) {
      const taskId = fallbackTaskId ?? null
      const slug = fallbackTaskId ? `CU-${fallbackTaskId}` : null
      return `## ClickUp Branch Parser Result

**Branch**: ${branch}
**Task ID**: ${taskId ?? "Not found"}
**Slug**: ${slug ?? "N/A"}
**Confidence**: 0

No ClickUp ID found in branch. Ensure the branch follows …-CU-123456 or provide fallbackTaskId.`
    }

    const primary = matches[0]
    const confidence = matches.length === 1 ? 1 : 0.75
    const matchList = matches.map((m) => `- ${m.slug} (ID: ${m.taskId})`).join("\n")

    return `## ClickUp Branch Parser Result

**Branch**: ${branch}
**Task ID**: ${primary.taskId}
**Slug**: ${primary.slug}
**Confidence**: ${confidence}

### Matches Found
${matchList}

${matches.length === 1 ? `Detected ClickUp ID ${primary.slug}.` : `Found multiple ClickUp IDs; defaulting to ${primary.slug}. Please verify.`}`
  }
})
