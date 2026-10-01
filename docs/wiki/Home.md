# aisdlc

**aisdlc** is a generic software-delivery add-on for [GitHub Spec Kit](https://github.com/github/spec-kit).
Spec Kit takes a feature from specification to implementation. aisdlc extends that into a full
lifecycle, so every change comes out reviewed, verified, documented, traceable and delivered as a
pull request.

It is built to stay compatible with every new Spec Kit release: it adds to Spec Kit's commands
instead of replacing them, and its CI tests against new upstream versions before each release.

## Who it is for

- Teams already using Spec Kit with an AI coding agent (Claude Code, GitHub Copilot, Cursor and others).
- Engineering leads who want spec-driven development with built-in quality gates and an audit trail.
- Organisations that need their own templates, branch rules or issue tracker. They add these through
  a separate organisation preset, without forking aisdlc.

## Where the project is now

**Phase: design, moving into the capability map.** No code has been released yet. Discovery is
done, and the parts of Spec Kit 1.0 that aisdlc may rely on (its public contract) are now pinned at
v1.0.13. Next is the capability map: deciding which capabilities aisdlc keeps, adapts or drops.

See [Roadmap](Roadmap) for the plan and [Decisions](Decisions) for what has been agreed so far.

## Start here

- [Product overview](Product-Overview): the workflows aisdlc will provide
- [Architecture](Architecture): how aisdlc sits on top of Spec Kit
- [Decisions](Decisions): what has been decided and why
- [Roadmap](Roadmap): phases and next steps

Source and full design notes: [vishalkhondre/speckit-aisdlc](https://github.com/vishalkhondre/speckit-aisdlc).
