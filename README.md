# enhanced-evil-paredit.el - Prevent Parenthesis Imbalance when Using Evil-mode with Paredit
![Build Status](https://github.com/jamescherti/enhanced-evil-paredit.el/actions/workflows/ci.yml/badge.svg)
[![MELPA](https://melpa.org/packages/enhanced-evil-paredit-badge.svg)](https://melpa.org/#/enhanced-evil-paredit)
[![MELPA Stable](https://stable.melpa.org/packages/enhanced-evil-paredit-badge.svg)](https://stable.melpa.org/#/enhanced-evil-paredit)
![License](https://img.shields.io/github/license/jamescherti/enhanced-evil-paredit.el)
![](https://jamescherti.com/misc/made-for-gnu-emacs.svg)

The **[enhanced-evil-paredit](https://github.com/jamescherti/enhanced-evil-paredit.el)** package prevents parenthesis imbalance when using *evil-mode* with *paredit*. It intercepts *evil-mode* commands such as delete, change, and paste, blocking their execution if they would break the parenthetical structure. This guarantees that your Lisp code remains syntactically correct while retaining the editing features of *evil-mode*.

If this enhances your workflow, please show your support by **⭐ starring enhanced-evil-paredit-mode on GitHub** to help more Emacs users discover its benefits.

## Installation

To install *enhanced-evil-paredit* from MELPA:

1. If you haven't already done so, [add MELPA repository to your Emacs configuration](https://melpa.org/#/getting-started).
2. Add the following code to the Emacs init file to install *enhanced-evil-paredit*:
```emacs-lisp
;; `paredit-mode' is a requirement
(use-package paredit
  :ensure t
  :commands paredit-mode
  :hook
  (emacs-lisp-mode . paredit-mode))

(use-package enhanced-evil-paredit
  :ensure t
  :commands enhanced-evil-paredit-mode
  :hook (paredit-mode . enhanced-evil-paredit-mode))
```

## Frequently asked questions

### What are the differences between enhanced-evil-paredit and evil-paredit?

The `enhanced-evil-paredit` package is a modernized version of `evil-paredit`. It has been enhanced and fully functions in recent versions of Emacs (Emacs >= 28). The author decided to develop `enhanced-evil-paredit` because the `evil-paredit` package is no longer maintained and does not function in recent versions of Emacs and Evil.

Here are the enhancements in `enhanced-evil-paredit`:
* Handles paste using `p` and `P`, ensuring that the pasted text has balanced parentheses.
* Fix call to a non-existent function `(evil-called-interactively-p)`, which has been replaced by `(called-interactively-p 'any)`.
* Add new functions: `enhanced-evil-paredit-backward-delete` and `enhanced-evil-paredit-forward-delete`.
* `enhanced-evil-paredit-mode` only uses the paredit functions when `paredit-mode` is enabled. It acts as a wrapper that delegates commands to Paredit when Paredit is enabled and otherwise uses standard Evil commands. (The difference in behavior is that with `paredit-mode`, structural editing operations preserve balanced parentheses and Lisp structure, whereas without `paredit-mode`, the same operations rely on Evil motions and can disrupt parentheses and overall code structure.)
* Add lexical binding with `lexical-binding: t`.
* Suppress Emacs Lisp warnings and add Melpa tests.
* Refactor and improve `enhanced-evil-paredit`.
* Create a `enhanced-evil-paredit` customization group for user configuration.
* Remove Evil state change from `enhanced-evil-paredit-mode`.
* Improve error handling in `enhanced-evil-paredit-check-region`.
* Enhance docstrings.
* Remove keymap bindings that are reserved by Emacs.
* Add `&optional` after the `end` argument to make it similar to Evil functions.
- `dd` restores the column when there is a parentheses mismatch.

## Author and License

The `enhanced-evil-paredit` Emacs package has been written by Roman Gonzalez and [James Cherti](https://www.jamescherti.com/). It is distributed under terms of the GNU General Public License version 3, or, at your choice, any later version.

Copyright (C) 2024-2026 James Cherti

Copyright (C) 2012-2015 Roman Gonzalez

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

## Links

- [enhanced-evil-paredit.el @GitHub](https://github.com/jamescherti/enhanced-evil-paredit.el)
- [enhanced-evil-paredit.el @MELPA](https://melpa.org/#/enhanced-evil-paredit)

Other Emacs packages by the same author:
- [minimal-emacs.d](https://github.com/jamescherti/minimal-emacs.d): This repository hosts a minimal Emacs configuration designed to serve as a foundation for your vanilla Emacs setup and provide a solid base for an enhanced Emacs experience.
- [compile-angel.el](https://github.com/jamescherti/compile-angel.el): **Speed up Emacs!** This package guarantees that all .el files are both byte-compiled and native-compiled, which significantly speeds up Emacs.
- [easysession.el](https://github.com/jamescherti/easysession.el): Easysession is lightweight Emacs session manager that can persist and restore file editing buffers, indirect buffers/clones, Dired buffers, the tab-bar, and the Emacs frames (with or without the Emacs frames size, width, and height).
- [vim-tab-bar.el](https://github.com/jamescherti/vim-tab-bar.el): Make the Emacs tab-bar Look Like Vim’s Tab Bar.
- [elispcomp](https://github.com/jamescherti/elispcomp): A command line tool that allows compiling Elisp code directly from the terminal or from a shell script. It facilitates the generation of optimized .elc (byte-compiled) and .eln (native-compiled) files.
- [tomorrow-night-deepblue-theme.el](https://github.com/jamescherti/tomorrow-night-deepblue-theme.el): The Tomorrow Night Deepblue Emacs theme is a beautiful deep blue variant of the Tomorrow Night theme, which is renowned for its elegant color palette that is pleasing to the eyes. It features a deep blue background color that creates a calming atmosphere. The theme is also a great choice for those who miss the blue themes that were trendy a few years ago.
- [Ultyas](https://github.com/jamescherti/ultyas/): A command-line tool designed to simplify the process of converting code snippets from UltiSnips to YASnippet format.
- [dir-config.el](https://github.com/jamescherti/dir-config.el): Automatically find and evaluate .dir-config.el Elisp files to configure directory-specific settings.
- [flymake-bashate.el](https://github.com/jamescherti/flymake-bashate.el): A package that provides a Flymake backend for the bashate Bash script style checker.
- [flymake-ansible-lint.el](https://github.com/jamescherti/flymake-ansible-lint.el): An Emacs package that offers a Flymake backend for `ansible-lint`.
- [inhibit-mouse.el](https://github.com/jamescherti/inhibit-mouse.el): A package that disables mouse input in Emacs, offering a simpler and faster alternative to the `disable-mouse` package.
- [quick-sdcv.el](https://github.com/jamescherti/quick-sdcv.el): This package enables Emacs to function as an offline dictionary by using the sdcv command-line tool directly within Emacs.
- [enhanced-evil-paredit.el](https://github.com/jamescherti/enhanced-evil-paredit.el): An Emacs package that prevents parenthesis imbalance when
using *evil-mode* with *paredit*. It intercepts *evil-mode* commands such as
delete, change, and paste, blocking their execution if they would break the
parenthetical structure.
- [stripspace.el](https://github.com/jamescherti/stripspace.el): Ensure Emacs Automatically removes trailing whitespace before saving a buffer, with an option to preserve the cursor column.
- [persist-text-scale.el](https://github.com/jamescherti/persist-text-scale.el): Ensure that all adjustments made with text-scale-increase and text-scale-decrease are persisted and restored across sessions.
- [pathaction.el](https://github.com/jamescherti/pathaction.el): Execute the pathaction command-line tool from Emacs. The pathaction command-line tool enables the execution of specific commands on targeted files or directories. Its key advantage lies in its flexibility, allowing users to handle various types of files simply by passing the file or directory as an argument to the pathaction tool. The tool uses a .pathaction.yaml rule-set file to determine which command to execute. Additionally, Jinja2 templating can be employed in the rule-set file to further customize the commands.
- [kirigami.el](https://github.com/jamescherti/kirigami.el): The *kirigami* Emacs package offers a unified interface for opening and closing folds across a diverse set of major and minor modes in Emacs, including `outline-mode`, `outline-minor-mode`, `outline-indent-minor-mode`, `org-mode`, `markdown-mode`, `vdiff-mode`, `vdiff-3way-mode`, `hs-minor-mode`, `hide-ifdef-mode`, `origami-mode`, `yafolding-mode`, `folding-mode`, and `treesit-fold-mode`. With Kirigami, folding key bindings only need to be configured **once**. After that, the same keys work consistently across all supported major and minor modes, providing a unified and predictable folding experience.
