#!/bin/bash

# Dev domain: compilers, language runtimes, build tools

pkg-add luarocks tree-sitter-cli postgresql-libs claude-code

# Language runtimes via mise
mise use --global node@latest
mise use --global bun@latest
mise use --global python@latest
curl -fsSL https://astral.sh/uv/install.sh | sh
mise use --global dotnet@latest
