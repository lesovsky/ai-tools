---
name: security-auditor
description: |
  Security analysis methodology: OWASP Top 10 coverage, hardcoded secrets
  detection, mode-aware analysis (code files vs tech-spec/architecture review).

  Loaded by dev-security-auditor agent. Use when analyzing code or specs for
  security vulnerabilities: "проверь безопасность", "security audit",
  "найди уязвимости", "check security"
---

# Security Auditor

## Analysis Mode

Determine mode from input:
- Received code files → audit implemented code for vulnerabilities
- Received tech-spec or task files → analyze proposed architecture for security risks

Err on the side of flagging issues. A false positive that gets reviewed and
dismissed is far cheaper than a false negative that produces a bad artifact.
When in doubt, create a finding.

## Mandatory Checks

Run regardless of mode:

### Hardcoded Secrets Detection

Scan for patterns: `API_KEY=`, `SECRET=`, `PASSWORD=`, `TOKEN=`,
base64-encoded strings that look like credentials, connection strings with
embedded passwords, private keys in source. Also check config files,
environment setup scripts, test fixtures with real credentials.
Any hardcoded secret → severity `critical`.

### Full OWASP Top 10 (2021) Coverage

1. **A01: Broken Access Control** — RBAC/ABAC, privilege escalation, IDOR, forced browsing
2. **A02: Cryptographic Failures** — weak algorithms, key management, plaintext storage
3. **A03: Injection** — SQL, NoSQL, OS command, LDAP, XSS (stored/reflected/DOM)
4. **A04: Insecure Design** — missing threat modeling, business logic flaws, missing security controls by design
5. **A05: Security Misconfiguration** — default credentials, unnecessary features, missing headers, CORS
6. **A06: Vulnerable Components** — dependencies with known CVEs, outdated packages
7. **A07: Auth Failures** — weak passwords, missing MFA, session management, credential stuffing
8. **A08: Software and Data Integrity** — CI/CD pipeline integrity, unsigned updates, insecure deserialization (`JSON.parse`/`pickle.loads`/`YAML.load` with untrusted input)
9. **A09: Security Logging and Monitoring** — missing audit trails for auth events, access denied, sensitive operations
10. **A10: SSRF** — URL from user input passed to fetch/axios/http.request without validation, internal network access

## Analysis Process

1. Review files systematically, starting with entry points (routes, controllers)
2. Trace data flow from input to output, identifying trust boundaries
3. Check auth at each protected endpoint
4. Examine all database queries for injection
5. Analyze user input handling and output encoding
6. Review cryptographic implementations
7. Verify security headers and CORS policies
8. Check dependency vulnerabilities

## Quality Guidelines

- Provide specific line numbers and code snippets for every finding
- Explain attack vector and potential impact in concrete terms
- Consider defense-in-depth already in place before flagging
- Every finding must have an implementable fix
- Flag uncertain framework protections for manual review rather than assuming safety
