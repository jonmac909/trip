# Trippified Subagent Delegation Rules

## When to Spawn Subagents

### 1. Planning Agent (`planner.md`)

**Spawn When**
- Starting a new feature (before any code)
- Breaking down a large task into subtasks
- User requests feature estimation

**Example Trigger**
```
User: "Implement the budget tracking feature"
→ Spawn planner.md to break down into tasks
```

### 2. Architect Agent (`architect.md`)

**Spawn When**
- Designing new data models
- Creating new API integrations
- Making architectural decisions
- Adding new Supabase tables

**Example Trigger**
```
User: "How should we structure the expense splitting feature?"
→ Spawn architect.md for design
```

### 3. TDD Guide Agent (`tdd-guide.md`)

**Spawn When**
- Starting implementation of any feature
- Writing tests for existing code
- Need help with test structure

**Example Trigger**
```
About to implement: calculateRouteOptimization()
→ Spawn tdd-guide.md to write tests first
```

### 4. Code Reviewer Agent (`code-reviewer.md`)

**Spawn When**
- After completing a feature
- Before creating a PR
- Code feels complex or uncertain

**Example Trigger**
```
Completed: Day Builder Overview Tab
→ Spawn code-reviewer.md for quality check
```

### 5. Security Reviewer Agent (`security-reviewer.md`)

**Spawn When**
- Adding authentication logic
- Handling user data
- Integrating external APIs
- Implementing document storage
- Any payment/booking related code

**Example Trigger**
```
Completed: Travel document upload feature
→ Spawn security-reviewer.md for audit
```

### 6. Build Error Resolver Agent (`build-error-resolver.md`)

**Spawn When**
- Build fails with unclear error
- Dependency conflicts
- Flutter/Dart compilation errors

**Example Trigger**
```
Error: type 'Null' is not a subtype of type 'String'
→ Spawn build-error-resolver.md
```

### 7. E2E Runner Agent (`e2e-runner.md`)

**Spawn When**
- Completing a user flow
- Before release
- After major refactoring

**Example Trigger**
```
Completed: Trip creation flow
→ Spawn e2e-runner.md to create integration tests
```

### 8. Refactor Cleaner Agent (`refactor-cleaner.md`)

**Spawn When**
- File exceeds 300 lines
- Function exceeds 50 lines
- Duplicate code detected
- After adding temporary code

**Example Trigger**
```
trip_repository.dart is now 350 lines
→ Spawn refactor-cleaner.md to split
```

### 9. Doc Updater Agent (`doc-updater.md`)

**Spawn When**
- API changes
- New feature completed
- Public interface changes

**Example Trigger**
```
Completed: Expense API endpoints
→ Spawn doc-updater.md to update docs
```

---

## Agent Interaction Rules

### Sequential vs Parallel

**Sequential** (one after another)
- Planning → TDD → Implementation → Review → Security

**Parallel** (can run together)
- Code Review + Security Review
- Multiple feature plannings

### Agent Output Handling

**Always**
- Read agent output completely
- Apply suggestions unless justified to skip
- Log any skipped suggestions with reason

### Agent Escalation

If agent output is unclear:
1. Ask for clarification
2. Provide more context
3. Break into smaller tasks

---

## Feature Development Workflow

```
1. User requests feature
   ↓
2. Spawn planner.md
   ↓
3. For each subtask:
   a. Spawn architect.md (if new design needed)
   b. Spawn tdd-guide.md
   c. Implement code
   d. Spawn code-reviewer.md
   e. Fix issues
   ↓
4. Spawn security-reviewer.md (if security-relevant)
   ↓
5. Spawn e2e-runner.md (for critical flows)
   ↓
6. Spawn doc-updater.md
   ↓
7. Create PR
```

---

## Task Size Guidelines

**Small Task** (no agent needed)
- Fix typo
- Update constant
- Add log statement

**Medium Task** (selective agents)
- Add new widget
- Implement single API call
- Write utility function

**Large Task** (full workflow)
- New feature
- New screen
- New integration
- Database changes
