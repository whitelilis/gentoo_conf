;;; hoogle.el --- functions for looking Haskell symbols up in Hoogle

;; Copyright (C) 2007

;; Author:  Andy Hefner <andy.hefner@verizon.net>, <clemens@endorphin.org>, David House <dmhouse@gmail.com>
;; Maintainer: David House <dmhouse@gmail.com>
;; Created: 2007
;; Version: 0.1
;; Keywords: doc, Haskell, Hoogle, search

;;; Commentary:

;; This code comes from hyperclim.el (public domain) and was originally written by
;; Andy Hefner (andy.hefner@verizon.net)
;; modified for Hoogle -- clemens@endorphin.org
;; Improved by David House <dmhouse@gmail.com> (BSD3 licensed)- Mar 07

;; This file is not part of GNU Emacs

(require 'browse-url)
(require 'haskell-mode)
(eval-when-compile (require 'cl))

(defvar hoogle-url-base "http://haskell.org/hoogle/?q="
  "The base for the URL that will be used for web Hoogle lookups.")
(defvar hoogle-local-command "hoogle"
  "The name of the executable used for Hoogle. If this isn't
found in $PATH (using `executable-find'), then a web lookup is used.")
(defvar hoogle-always-use-web nil
  "Set to non-nil to always use web lookups.")
(defvar hoogle-history nil
  "The history of what you've Hoogled for.")

(defun hoogle-lookup (p)
  "Lookup the identifier at point in Hoogle. If we can't find an
identifier at the point, or with a prefix arg of 1, prompts for a
name to look up. If we can find a Hoogle in the $PATH (using
`executable-find' on `hoogle-local-command'), it will be used,
unless `hoogle-always-use-web' is non-nil. For web Hoogling, the
name is appended to `hoogle-url-base' and `browse-url' is
invoked."
  (interactive "p")
  (let ((symbol-name (haskell-ident-at-point)))
    ;; Read a name to lookup from the minibuffer if we couldn't find one in the
    ;; file.
    (unless (and (= 1 p) (stringp symbol-name))
      (setq symbol-name
            (read-from-minibuffer
             "Hoogle lookup name: " "" nil nil 'hoogle-history)))
    ;; If we can find a local Hoogle, and the user hasn't told us to always use
    ;; a web Hoogle, use the local Hoogle, otherwise use the web Hoogle.
    (if (and (not hoogle-always-use-web)
             (fboundp 'executable-find)
             (executable-find hoogle-local-command))
        (let ((b (get-buffer-create "*Hoogle output*")))
          (shell-command (concat "hoogle " symbol-name) b)
          (with-current-buffer b
            (toggle-read-only)
            (set-buffer-modified-p nil)))
      (browse-url (concat hoogle-url-base symbol-name)))))

(provide 'hoogle)
;;; hoogle.el ends here
