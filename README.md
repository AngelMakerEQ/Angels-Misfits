# Angels-Misfits

Angels Misfits is a long-term EverQuest Emulator (EQEmu) project focused on recreating the spirit of classic EverQuest while balancing historical authenticity, maintainability, compatibility, and long-term development.

Rather than reproducing every historical limitation, the project aims to preserve the gameplay, atmosphere, progression, and social experience that defined classic EverQuest while leveraging modern EQEmu infrastructure and development practices where they improve stability, maintainability, or administration without meaningfully changing the player experience.

The project's current design target is the Velious era. Future expansion into later eras may be considered if it aligns with the project's guiding philosophy and long-term goals.

---

# Guiding Principles

- Preserve the intended gameplay experience of the project's current target era.
- Favor historical authenticity where players directly experience it.
- Favor maintainability, compatibility, and stability where players do not.
- Reuse existing EQEmu systems whenever practical before introducing custom implementations.
- Document significant architectural and gameplay decisions.
- Maintain a repository that can continue evolving for many years.

---

# Technology Stack

- EQEmu
- Rain of Fire 2 (RoF2) Client
- MariaDB
- HeidiSQL
- Spire
- Lua
- Perl
- C++
- EQEmu MCP
- GitHub (Project Documentation & Source of Truth)

---

# Repository Purpose

This repository serves as the authoritative source of truth for the Angels Misfits project.

Its purpose is to document:

- Project architecture
- Database design
- Gameplay philosophy
- Client customization
- Historical research
- Compatibility requirements
- Development standards
- Architectural Decision Records (ADRs)
- Project roadmap
- Current project status

When documentation exists, it takes precedence over conversation history or memory.

---

# Repository Structure

```text
README.md
PROJECT_STATUS.md
ROADMAP.md
CHANGELOG.md

docs/
├── architecture/
├── assets/
├── client/
├── compatibility/
├── database/
├── decisions/
├── development/
├── gameplay/
├── quests/
└── research/

scripts/
```

Each document has a single primary purpose. Information should be maintained in its authoritative location and referenced elsewhere rather than duplicated across multiple documents.

---

# Development Workflow

Development follows these general principles:

1. Understand the existing system.
2. Research historical behavior when appropriate.
3. Review existing project documentation.
4. Recommend the simplest maintainable solution.
5. Implement the change.
6. Validate the results.
7. Update project documentation whenever a change affects the project's long-term knowledge.

---

# Getting Started

- See **PROJECT_STATUS.md** for the current state of the project.
- See **ROADMAP.md** for planned milestones and priorities.
- Begin with the documents under **docs/architecture/** to understand the project's design philosophy and architecture.