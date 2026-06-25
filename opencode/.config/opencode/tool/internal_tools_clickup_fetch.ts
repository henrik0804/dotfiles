import { tool } from "@opencode-ai/plugin"

const API_BASE = "https://internal.cre8-it.de/api/v1/clickup/tasks"
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0"

interface TaskStatus {
  status: string
  type: string
  color: string
  orderindex: string
}

interface TaskPriority {
  id: string
  priority: string
  color: string
  orderindex: string
}

interface TaskResource {
  id: string
  custom_id: string | null
  name: string
  text_content: string | null
  description: string | null
  status: TaskStatus
  priority: TaskPriority | null
  due_date: string | null
  url: string
  subtasks: TaskResource[] | null
}

function formatTask(task: TaskResource, isSubtask = false): string {
  const prefix = isSubtask ? "###" : "##"
  const lines: string[] = []

  lines.push(`${prefix} ${task.name}`)
  lines.push("")

  if (task.custom_id) {
    lines.push(`**Custom ID**: ${task.custom_id}`)
  }
  lines.push(`**Task ID**: ${task.id}`)
  lines.push(`**Status**: ${task.status?.status ?? "Unknown"}`)

  if (task.priority?.priority) {
    lines.push(`**Priority**: ${task.priority.priority}`)
  }

  if (task.due_date) {
    const dueDate = new Date(parseInt(task.due_date))
    lines.push(`**Due Date**: ${dueDate.toLocaleDateString()}`)
  }

  if (task.url) {
    lines.push(`**URL**: ${task.url}`)
  }

  lines.push("")

  if (task.text_content) {
    lines.push("**Content**:")
    lines.push("")
    lines.push(task.text_content)
    lines.push("")
  } else if (task.description) {
    lines.push("**Description**:")
    lines.push("")
    lines.push(task.description)
    lines.push("")
  }

  return lines.join("\n")
}

export default tool({
  description:
    "Fetches ClickUp task details via the internal tools service. (Signature only; HTTP integration pending.)",
  args: {
    taskId: tool.schema
      .string()
      .min(4)
      .describe("ClickUp task ID, e.g. 123456abc"),
    includeSubtasks: tool.schema
      .boolean()
      .optional()
      .default(false)
      .describe("Include Subtasks"),
  },
  async execute({ taskId, includeSubtasks }) {
    const bearerToken = process.env.CLICKUP_INTERNAL_TOOLS_TOKEN

    if (!bearerToken) {
      return `## ClickUp Task Fetch Error

**Task ID**: ${taskId}
**Error**: CLICKUP_INTERNAL_TOOLS_TOKEN is not set.

> Set CLICKUP_INTERNAL_TOOLS_TOKEN in the environment before using this tool.`
    }

    const url = `${API_BASE}/${taskId}?include_subtasks=${includeSubtasks ? "true" : "false"}`

    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          Authorization: `Bearer ${bearerToken}`,
          Accept: "application/json",
          "Content-Type": "application/json",
        },
      })

      if (!response.ok) {
        const errorText = await response.text()
        return `## ClickUp Task Fetch Error

**Task ID**: ${taskId}
**Status**: ${response.status} ${response.statusText}
**Error**: ${errorText || "Request failed"}

> Check that the task ID is valid and the internal tools service is accessible.`
      }

      const task: TaskResource = (await response.json()).data

      const sections: string[] = []
      sections.push("# ClickUp Task Details")
      sections.push("")
      sections.push(formatTask(task))

      if (includeSubtasks && task.subtasks && task.subtasks.length > 0) {
        sections.push("---")
        sections.push("")
        sections.push("## Subtasks")
        sections.push("")

        for (const subtask of task.subtasks) {
          sections.push(formatTask(subtask, true))
          sections.push("")
        }
      } else if (includeSubtasks && (!task.subtasks || task.subtasks.length === 0)) {
        sections.push("")
        sections.push("*No subtasks found.*")
      }

      return sections.join("\n")
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error)
      return `## ClickUp Task Fetch Error

**Task ID**: ${taskId}
**Error**: ${errorMessage}

> Network error or service unavailable. Check connectivity to internal-tools.test.`
    }
  },
})
