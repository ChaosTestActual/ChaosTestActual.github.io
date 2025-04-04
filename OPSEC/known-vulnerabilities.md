# OPSEC Known Vulnerabilities

## Markdown Preview Enhanced Extension in VS Code

### Description

The [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced) extension for VS Code is used to enable working anchor links in Markdown files. It provides a rich preview experience with better support for table of contents navigation and rendering features like LaTeX, charts, and more.

### Risk

- The extension is published by an **unverified author (Yiyi Wang)** on the VS Code Marketplace.
- It has the capability to execute embedded JavaScript and other code blocks within Markdown previews, which introduces a potential risk if malicious Markdown files are opened.
- The extension has over 2 million installs but lacks formal publisher verification by Microsoft.

### Mitigation & Reasoning

Despite the risks, it is being used in this project for the following reasons:

- All Markdown content previewed through this extension is **locally authored and trusted** (i.e. not from unknown sources).
- The extension is **open source and actively maintained**, and the codebase is publicly auditable.
- Functionality is critical to verifying that anchor links in documentation work as expected before deployment.
- The user has accepted a philosophy that "perfection is the enemy of progress/happiness" and opted for pragmatic tooling over strict trust models in this case.

This decision is reviewed periodically, and the extension may be removed if a verified alternative becomes available or if its trust posture changes.
