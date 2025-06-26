# .claude/CLAUDE.md - Local Claude Code Configuration

This file provides local guidance to Claude Code when working within this specific workspace, overriding any root-level CLAUDE.md configurations.

## Command Argument Validation Workflow

When executing commands defined in `.claude/commands/`, the following workflow applies:

### Argument Validation Rule

**For commands requiring arguments:**

1. **Check Arguments**: Verify if required arguments are provided
2. **Missing Arguments Action**:
   - Display error message: `⏺ Please provide required arguments`
   - Log termination reason
   - **Skip "Update Todos" phase**
   - **Terminate processing immediately**
   - **Do NOT proceed with any command execution**

3. **Arguments Provided**: Continue with normal command processing

### Implementation Pattern

```bash
# Command execution pattern
if [[ -z "${REQUIRED_ARG}" ]]; then
    echo "⏺ Please provide required arguments"
    echo "📝 Terminating: Missing required arguments"
    exit 0
fi

# Continue with command processing...
```

## Root CLAUDE.md Override

**IMPORTANT**: This local `.claude/CLAUDE.md` configuration **overrides** and **ignores** the root-level CLAUDE.md file located at the project root.

- Root CLAUDE.md path: `/path/to/flutter_whisper_kit/CLAUDE.md` (IGNORED)
- Local CLAUDE.md path: `/path/to/flutter_whisper_kit/.claude/CLAUDE.md` (ACTIVE)

## Command-Specific Rules

### WhisperKit Integration Commands

Commands defined in `.claude/commands/` directory must implement consistent argument validation:

1. Check for required arguments
2. Early termination if missing
3. Skip todos/cleanup phases
4. Log reason for termination

## Workspace Isolation

This workspace operates in isolation from the root project configuration:

- **Independent command execution**
- **Separate memory/context**
- **Local-only configuration rules**
- **Override root-level instructions**

## Priority Order

Configuration priority (highest to lowest):

1. `.claude/CLAUDE.md` (this file) - **HIGHEST PRIORITY**
2. `.claude/commands/*.md` - Command-specific configurations
3. Local environment variables
4. Root CLAUDE.md - **IGNORED IN THIS WORKSPACE**

---

**Note**: This configuration ensures consistent argument validation across all custom commands while maintaining workspace isolation from root project settings.