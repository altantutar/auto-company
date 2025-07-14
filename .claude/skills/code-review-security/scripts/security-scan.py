#!/usr/bin/env python3
"""
security-scan.py — AST-based security scanner for common Python vulnerability patterns.

Scans Python source files for:
  - eval() / exec() / compile() calls
  - subprocess with shell=True
  - pickle.loads() on potentially untrusted data
  - Raw SQL string construction (f-strings with SELECT/INSERT/UPDATE/DELETE)
  - yaml.load() without SafeLoader
  - Hardcoded secret patterns (API keys, passwords in source)
  - Weak hash functions (MD5, SHA1 for passwords)
  - os.system() calls

Usage:
  python security-scan.py --path ./app --output-dir ./security-results
  python security-scan.py --path ./app --output-dir ./results --severity high

Options:
  --path         Directory or file to scan (required)
  --output-dir   Directory to write JSON results (default: ./security-results)
  --severity     Minimum severity to report: critical, high, medium, low (default: low)
"""

import argparse
import ast
import json
import os
import re
import sys
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional


# ─── Data Structures ─────────────────────────────────────────────────────────────

SEVERITY_ORDER = {"critical": 0, "high": 1, "medium": 2, "low": 3, "info": 4}


@dataclass
class Finding:
    """A single security finding."""
    rule_id: str
    severity: str
    category: str
    message: str
    file: str
    line: int
    col: int
    snippet: str
    cwe: Optional[str] = None


# ─── AST-Based Rules ─────────────────────────────────────────────────────────────

class SecurityVisitor(ast.NodeVisitor):
    """AST visitor that checks for common security anti-patterns."""

    def __init__(self, filepath: str, source_lines: list[str]):
        self.filepath = filepath
        self.source_lines = source_lines
        self.findings: list[Finding] = []

    def _get_snippet(self, lineno: int) -> str:
        """Get the source line for a finding."""
        if 1 <= lineno <= len(self.source_lines):
            return self.source_lines[lineno - 1].strip()
        return ""

    def _add_finding(
        self,
        rule_id: str,
        severity: str,
        category: str,
        message: str,
        node: ast.AST,
        cwe: Optional[str] = None,
    ):
        self.findings.append(Finding(
            rule_id=rule_id,
            severity=severity,
            category=category,
            message=message,
            file=self.filepath,
            line=getattr(node, "lineno", 0),
            col=getattr(node, "col_offset", 0),
            snippet=self._get_snippet(getattr(node, "lineno", 0)),
            cwe=cwe,
        ))

    def visit_Call(self, node: ast.Call):
        """Check function calls for dangerous patterns."""
        func_name = self._get_func_name(node)

        # Rule: eval / exec / compile
        if func_name in ("eval", "exec", "compile"):
            self._add_finding(
                rule_id="SEC001",
                severity="critical",
                category="OWASP A03: Injection",
                message=f"Use of {func_name}() can lead to code execution. "
                        f"Remove or use ast.literal_eval() for safe parsing.",
                node=node,
                cwe="CWE-95",
            )

        # Rule: pickle.loads / pickle.load
        if func_name in ("pickle.loads", "pickle.load"):
            self._add_finding(
                rule_id="SEC002",
                severity="critical",
                category="OWASP A08: Software and Data Integrity",
                message="pickle.loads() can execute arbitrary code on untrusted data. "
                        "Use JSON or msgpack for deserialization.",
                node=node,
                cwe="CWE-502",
            )

        # Rule: os.system
        if func_name == "os.system":
            self._add_finding(
                rule_id="SEC003",
                severity="high",
                category="OWASP A03: Injection",
                message="os.system() is vulnerable to command injection. "
                        "Use subprocess.run([...], shell=False) instead.",
                node=node,
                cwe="CWE-78",
            )

        # Rule: subprocess with shell=True
        if func_name in ("subprocess.run", "subprocess.call", "subprocess.Popen",
                         "subprocess.check_output", "subprocess.check_call"):
            for kw in node.keywords:
                if kw.arg == "shell" and isinstance(kw.value, ast.Constant) and kw.value.value is True:
                    self._add_finding(
                        rule_id="SEC004",
                        severity="high",
                        category="OWASP A03: Injection",
                        message=f"{func_name}() with shell=True is vulnerable to "
