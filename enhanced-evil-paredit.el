;;; enhanced-evil-paredit.el --- Paredit support for evil keybindings  -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024-2026 James Cherti | https://www.jamescherti.com/contact/
;; Copyright (C) 2012-2015 Roman Gonzalez

;; Mantainer: James Cherti
;; Original author: Roman Gonzalez <romanandreg@gmail.com>
;; Version: 1.0.5
;; URL: https://github.com/jamescherti/enhanced-evil-paredit.el
;; Keywords: convenience
;; Package-Requires: ((emacs "24.1") (evil "1.0.9") (paredit "25beta"))
;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; The enhanced-evil-paredit package prevents parenthesis imbalance when using
;; evil-mode with paredit.
;;
;; It intercepts evil-mode commands such as delete, change, and paste, blocking
;; their execution if they would break the parenthetical structure. This
;; guarantees that your Lisp code remains syntactically correct while retaining
;; the editing features of evil-mode.
;;
;; Installation from MELPA:
;; ------------------------
;; ;; `paredit-mode' is a requirement
;; (use-package paredit
;;   :commands paredit-mode
;;   :hook
;;   (emacs-lisp-mode . paredit-mode))
;;
;; (use-package enhanced-evil-paredit
;;   :commands enhanced-evil-paredit-mode
;;   :hook (paredit-mode . enhanced-evil-paredit-mode))
;;
;; Links:
;; ------
;; - enhanced-evil-paredit @GitHub:
;;   https://github.com/jamescherti/enhanced-evil-paredit.el

;;; Code:

(eval-and-compile
  (require 'evil))
(require 'paredit)

(defgroup enhanced-evil-paredit nil
  "Evil Customization group for paredit-style structural editing."
  :group 'enhanced-evil-paredit
  :prefix "enhanced-evil-paredit-")

(defcustom enhanced-evil-paredit-handle-paste nil
  "Non-nil to prevent parenthesis imbalance when pressing p or P in normal mode.
This is an experimental feature."
  :type 'boolean
  :group 'enhanced-evil-paredit)

(defvar enhanced-evil-paredit-mode-map (make-sparse-keymap)
  "Keymap for `enhanced-evil-paredit-mode'.")

;;;###autoload
(define-minor-mode enhanced-evil-paredit-mode
  "Minor mode for setting up Evil with paredit in a single buffer."
  :lighter " EParedit"
  :group 'enhanced-evil-paredit
  :keymap enhanced-evil-paredit-mode-map
  (when (and enhanced-evil-paredit-mode
             (fboundp 'eldoc-add-command-completions))
    (eldoc-add-command-completions "enhanced-evil-paredit-")
    (eldoc-add-command-completions "paredit-")))

(defun enhanced-evil-paredit--check-region (beg end)
  "Ensure region from BEG to END maintains parenthesis balance.
Signals an error if deleting the region would break structure."
  (when (and beg end)
    (if (fboundp 'paredit-check-region-state)
        (save-excursion
          (goto-char beg)
          (let* ((state (paredit-current-parse-state))
                 (state* (parse-partial-sexp beg end nil nil state)))
            (paredit-check-region-state state state*)))
      (paredit-check-region-for-delete beg end))))

(evil-define-operator enhanced-evil-paredit-yank
  (beg end &optional type register yank-handler)
  "Yank text from BEG to END of TYPE into REGISTER with YANK-HANDLER."
  :move-point nil
  :repeat nil
  (interactive "<R><x><y>")
  (cond
   ((bound-and-true-p paredit-mode)
    (enhanced-evil-paredit--check-region beg end)
    (cond
     ((eq type 'block)
      (evil-yank-rectangle beg end register yank-handler))
     ((eq type 'line)
      (evil-yank-lines beg end register yank-handler))
     (t
      (evil-yank-characters beg end register yank-handler))))

   (t
    (evil-yank beg end type register yank-handler))))

(evil-define-operator enhanced-evil-paredit-yank-line
  (beg end &optional type register)
  "Saves whole lines into the `kill-ring'."
  :motion evil-line
  :move-point nil
  (interactive "<R><x>")
  (cond
   ((bound-and-true-p paredit-mode)
    (let* ((beg (point))
           (end (enhanced-evil-paredit-kill-end)))
      (enhanced-evil-paredit-yank beg end type register)))

   (t
    (evil-yank-line beg end type register))))

(evil-define-operator enhanced-evil-paredit-delete
  (beg end &optional type register yank-handler)
  "Delete text from BEG to END with TYPE respecting parenthesis.
Save in REGISTER or in the `kill-ring' with YANK-HANDLER."
  (interactive "<R><x><y>")
  (let ((restore-column nil))
    (unwind-protect
        (cond
         ((bound-and-true-p paredit-mode)
          (setq restore-column t)
          (enhanced-evil-paredit-yank beg end type register yank-handler)
          (setq restore-column nil)
          (if (eq type 'block)
              (evil-apply-on-block #'delete-region beg end nil)

            (delete-region beg end))
          ;; Place cursor on beginning of line
          (when (and (called-interactively-p 'any)
                     (eq type 'line))
            (evil-first-non-blank)))

         (t
          (setq restore-column nil)
          (evil-delete beg end type register yank-handler)))
      (when (and restore-column (boundp 'evil-operator-start-col))
        (move-to-column evil-operator-start-col)))))

(evil-define-operator enhanced-evil-paredit-delete-line
  (beg end &optional type register yank-handler)
  "Delete to end of line respecting parenthesis."
  :motion evil-end-of-line-or-visual-line
  (interactive "<R><x>")
  (cond
   ((bound-and-true-p paredit-mode)
    (let* ((beg (point))
           (end (enhanced-evil-paredit-kill-end)))
      (enhanced-evil-paredit-delete beg end
                                    type register yank-handler)))

   (t
    (evil-delete-line beg end type register yank-handler))))

(defun enhanced-evil-paredit-kill-end ()
  "Return the position where `paredit-kill' would kill to."
  (when (paredit-in-char-p)             ; Move past the \ and prefix.
    (backward-char 2))                  ; (# in Scheme/CL, ? in elisp)
  (let* ((eol (line-end-position))
         (end-of-list-p (save-excursion
                          (paredit-forward-sexps-to-kill (point) eol))))
    (if end-of-list-p (progn (up-list) (backward-char)))
    (cond
     ((paredit-in-string-p)
      (if (save-excursion (paredit-skip-whitespace t (line-end-position))
                          (eolp))
          (kill-line)
        (save-excursion
          ;; Be careful not to split an escape sequence.
          (if (paredit-in-string-escape-p)
              (backward-char))
          (min (line-end-position)
               (cdr (paredit-string-start+end-points))))))

     ((paredit-in-comment-p)
      eol)

     (t (if (and (not end-of-list-p)
                 (eq (line-end-position) eol))
            eol
          (point))))))

(evil-define-operator enhanced-evil-paredit-change
  (beg end type register yank-handler &optional delete-func)
  "Change text from BEG to END of TYPE using REGISTER and YANK-HANDLER.
Save in REGISTER or the `kill-ring' with YANK-HANDLER.
DELETE-FUNC is a function for deleting text, default `evil-delete'.
If TYPE is `line', insertion starts on an empty line.
If TYPE is `block', the inserted text in inserted at each line
of the block."
  (interactive "<R><x><y>")
  (let ((delete-func (or delete-func #'enhanced-evil-paredit-delete))
        (nlines (1+ (- (line-number-at-pos end)
                       (line-number-at-pos beg)))))
    (funcall delete-func beg end type register yank-handler)
    (cond
     ((eq type 'line)
      (evil-open-above 1))
     ((eq type 'block)
      (evil-insert 1 nlines))
     (t
      (evil-insert 1)))))

(evil-define-operator enhanced-evil-paredit-change-line
  (beg end type register yank-handler)
  "Yank line from BEG to END of TYPE into REGISTER."
  :motion evil-end-of-line
  (interactive "<R><x><y>")
  (let* ((beg (point))
         (end (enhanced-evil-paredit-kill-end)))
    (enhanced-evil-paredit-change beg end type register yank-handler)))

(defun enhanced-evil-paredit-change-whole-line ()
  "Change whole line."
  (interactive)
  (goto-char (line-beginning-position))
  (enhanced-evil-paredit-change-line nil nil)
  (indent-according-to-mode))

(evil-define-operator enhanced-evil-paredit-backward-delete
  (beg end type register yank-handler)
  "Delete character forward.
Delete the character forward from BEG to END of TYPE into REGISTER with
YANK-HANDLER."
  :motion evil-backward-char
  :keep-visual t
  (interactive "<r><x><y>")
  (if (and beg end)
      (enhanced-evil-paredit-delete beg end type register yank-handler)
    (enhanced-evil-paredit-delete
     (1- (point)) (point) type register yank-handler)))

(evil-define-operator enhanced-evil-paredit-forward-delete
  (beg end type register yank-handler)
  "Delete character at point."
  :motion evil-forward-char
  :keep-visual t
  (interactive "<r><x><y>")
  (if (and beg end)
      (enhanced-evil-paredit-delete beg end type register yank-handler)
    (enhanced-evil-paredit-delete
     (point) (1+ (point)) type register yank-handler)))

(evil-define-command enhanced-evil-paredit--paste-funcall
  (paste-func count &optional register yank-handler)
  "Paste the latest yanked text using PASTE-FUNC function.
COUNT, REGISTER, and YANK-HANDLER are the same arguments as `evil-paste-after'
and `evil-paste-before'.
The return value is the yanked text."
  (cond
   ((or (not enhanced-evil-paredit-handle-paste)
        (not (bound-and-true-p paredit-mode)))
    (funcall paste-func count register yank-handler))

   (t (let ((undo-handle (prepare-change-group))
            ;; Don't truncate any undo data in the middle of this, otherwise
            ;; Emacs might truncate part of the resulting undo step.
            (undo-outer-limit nil)
            (undo-limit most-positive-fixnum)
            (undo-strong-limit most-positive-fixnum)
            (point (point)))
        (unwind-protect
            (progn
              (funcall paste-func count register yank-handler)
              (let ((beg (progn (evil-goto-mark ?\[) (point)))
                    (end (progn (evil-goto-mark ?\]) (+ 1 (point)))))
                (let ((error t))
                  (unwind-protect
                      (progn
                        (enhanced-evil-paredit--check-region beg end)
                        (setq error nil))
                    (when error
                      (evil-delete beg end nil ?_)
                      (goto-char point))))))
          (accept-change-group undo-handle)
          (undo-amalgamate-change-group undo-handle))))))

(evil-define-command enhanced-evil-paredit-paste-after
  (count &optional register yank-handler)
  "Paste the latest yanked text behind point.
COUNT, REGISTER, and YANK-HANDLER are the same arguments as `evil-paste-after'
and `evil-paste-before'.
The return value is the yanked text."
  :suppress-operator t
  (interactive "*P<x>")
  (enhanced-evil-paredit--paste-funcall #'evil-paste-after count register yank-handler))

(evil-define-command enhanced-evil-paredit-paste-before
  (count &optional register yank-handler)
  "Paste the latest yanked text before the cursor position.
COUNT, REGISTER, and YANK-HANDLER are the same arguments as `evil-paste-after'
and `evil-paste-before'.
The return value is the yanked text."
  :suppress-operator t
  (interactive "*P<x>")
  (enhanced-evil-paredit--paste-funcall #'evil-paste-before count register yank-handler))

(evil-define-key 'normal enhanced-evil-paredit-mode-map
  (kbd "P") #'enhanced-evil-paredit-paste-before
  (kbd "p") #'enhanced-evil-paredit-paste-after
  (kbd "d") #'enhanced-evil-paredit-delete
  (kbd "c") #'enhanced-evil-paredit-change
  (kbd "y") #'enhanced-evil-paredit-yank
  (kbd "D") #'enhanced-evil-paredit-delete-line
  (kbd "C") #'enhanced-evil-paredit-change-line
  (kbd "S") #'enhanced-evil-paredit-change-whole-line
  (kbd "Y") #'enhanced-evil-paredit-yank-line
  (kbd "X") #'enhanced-evil-paredit-backward-delete
  (kbd "x") #'enhanced-evil-paredit-forward-delete)

(provide 'enhanced-evil-paredit)

;;; enhanced-evil-paredit.el ends here
