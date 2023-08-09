;;; macos.el --- MacOS utils. -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2017 Yevgnen Koh
;;
;; Author: Yevgnen Koh <wherejoystarts@gmail.com>
;; Version: 0.0.1
;; Keywords: macos
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;;
;;
;; See documentation on https://github.com/Yevgnen/macos.el.

;;; Code:

;;;###autoload
(defun macos-quicklook-file (path)
  (interactive)
  (when (and IS-MAC
             (executable-find "qlmanage"))
    (defvar cur nil)
    (defvar old nil)
    (setq old cur)
    (setq cur (start-process "ql-file" nil "qlmanage" "-p" path))
    (when old (delete-process old))))

;;;###autoload
(defun macos-read-string-from-safari ()
  (interactive)
  (string-trim
   (do-applescript
    (concat "tell application \"Safari\"\n"
            "\tset page_source to the source of document 1\n"
            "\treturn page_source\n"
            "end tell\n"))))

;;;###autoload
(defun osx-switch-back-to-previous-application ()
  "Switch back to previous application on macOS."
  (interactive)
  (do-applescript
   (mapconcat
    #'identity
    '("tell application \"System Events\""
      "  tell process \"Finder\""
      "    activate"
      "    keystroke tab using {command down}"
      "  end tell"
      "end tell")
    "\n")))

;; References: https://nickdrozd.github.io/2019/12/28/emacs-mac-mods.html
;; Modify default keys.
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)
(setq mac-control-modifier 'control)

;; Steal from doom-emacs.
(setq mac-mouse-wheel-smooth-scroll nil)
(setq mac-redisplay-dont-reset-vscroll t)

;; Integrate with Keychain.
(with-eval-after-load 'auth-source
  (dolist (source '(macos-keychain-internet macos-keychain-generic))
    (cl-pushnew source auth-sources)))

;; Dired support.
(defun dired-quicklook ()
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (if (file-directory-p file)
        (or (and (cdr dired-subdir-alist)
                 (dired-goto-subdir file))
            (dired file))
      (save-selected-window
        (macos-quicklook-file file)))))

(with-eval-after-load 'dired
  (bind-keys :map dired-mode-map ("SPC" . dired-quicklook)))

(provide 'macos)

;;; macos.el ends here
