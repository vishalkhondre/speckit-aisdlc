# aisdlc bundle

Installs the aisdlc extension, preset and feature workflow at one version on top of a stock Spec Kit
(`specify-cli`). aisdlc composes with Spec Kit's core commands instead of replacing them, and keeps
`specs/<feature>/` durable.

Status: skeleton. Commands and workflow steps arrive in later phases.

- Requires Spec Kit `>=1.0.5,<2.0.0`.
- Works with any integration (no integration pin).
- Install from a checkout: `scripts/dev/install-local.sh <project-dir>`. Catalog-based installation
  arrives with the first release.

Licence: MIT. Source: https://github.com/vishalkhondre/speckit-aisdlc
