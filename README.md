# Windows-Aliases 🖥️

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://img.shields.io/github/license/gvatsal60/Windows-Aliases)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/gvatsal60/Windows-Aliases/master.svg)](https://results.pre-commit.ci/latest/github/gvatsal60/Windows-Aliases/HEAD)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/93a421b968b049839d8266e8ef94bd08)](https://app.codacy.com/gh/gvatsal60/Windows-Aliases/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![CodeFactor](https://www.codefactor.io/repository/github/gvatsal60/windows-aliases/badge)](https://www.codefactor.io/repository/github/gvatsal60/windows-aliases)
![GitHub pull-requests](https://img.shields.io/github/issues-pr/gvatsal60/Windows-Aliases)
![GitHub Issues](https://img.shields.io/github/issues/gvatsal60/Windows-Aliases)
![GitHub forks](https://img.shields.io/github/forks/gvatsal60/Windows-Aliases)
![GitHub stars](https://img.shields.io/github/stars/gvatsal60/Windows-Aliases)

Simplify your Windows PowerShell workflow with a curated set of practical aliases and
helper functions for file navigation, Git, Docker, and Terraform commands.

## Table of Contents

- [📝 Introduction](#introduction)
- [🚀 Usage](#usage)
- [✅ Supported Platforms](#supported-platforms)
- [🤝 Contributing](#contributing)
- [📄 License](#license)

## Introduction

This repository provides:

1. `.aliases.ps1` – reusable PowerShell aliases/functions
2. `install.ps1` – installer script that downloads aliases and wires them into your PowerShell profile

## Usage

Run the installer from PowerShell:

```powershell
irm https://raw.githubusercontent.com/gvatsal60/Windows-Aliases/HEAD/install.ps1 | iex
```

Then reload your profile (or restart terminal):

```powershell
. $PROFILE
```

## Supported Platforms

- Windows PowerShell 5.1 on Windows
- PowerShell 7+ on Windows

## Contributing

Contributions are welcome. If you want to add or improve aliases, feel free to open a pull request.
Please follow the [CONTRIBUTING.md](./CONTRIBUTING.md) guidelines.

## License

This project is licensed under the Apache 2.0 License.
See the [LICENSE](./LICENSE) file for details.
