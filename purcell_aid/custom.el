(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector (vector "#657b83" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#fdf6e3"))
 '(cua-enable-cua-keys nil)
 '(custom-enabled-themes (quote (sanityinc-solarized-dark)))
 '(custom-safe-themes (quote ("4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4" default)))
 '(fci-rule-color "#eee8d5")
; '(menu-bar-mode nil)
; '(global-linum-mode t)
 '(org-export-latex-packages-alist '(("" "CJKutf8" t)))
 '(safe-local-variable-values (quote ((Package . CL-USER) (Syntax . COMMON-LISP) (Syntax . ANSI-Common-Lisp) (Base . 10) (Package . CCL) (ruby-compilation-executable . "ruby") (ruby-compilation-executable . "ruby1.8") (ruby-compilation-executable . "ruby1.9") (ruby-compilation-executable . "rbx") (ruby-compilation-executable . "jruby"))))
 '(session-use-package t nil (session)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; wizard code start here
;; zoo
(setq backup-directory-alist '(("." . "~/back")))


;; rainbow-delimiters-mode is good, add for all
(global-rainbow-delimiters-mode)

(setq slime-autodoc-use-multiline-p t)
;; default use sbcl
(setq slime-default-lisp 'sbcl)
(global-set-key "\C-cs" 'slime-selector)
(eval-after-load 'slime
  '(progn
     (slime-setup '(slime-fancy slime-xref-browser slime-scratch))
     (setq slime-autodoc-use-multiline-p t)))


;;; for time display
(setq display-time-24hr-format t)
(setq display-time-format "%Y-%m-%d %R")
(display-time)

;; larger font
;(increment-default-font-height 20)


;;; for perl mode
(defalias 'perl-mode 'cperl-mode)
(add-hook 'cperl-mode-hook 'n-cperl-mode-hook t)
(defun n-cperl-mode-hook ()
  (paredit-mode)
  (setq cperl-indent-level 8)
  (setq cperl-continued-statement-offset 0)
;  (setq cperl-extra-newline-before-brace t)
;  (set-face-background 'cperl-array-face "blue")
;  (set-face-background 'cperl-hash-face "red")
  )


;;; frenquency used command in slime repl
(defun change-pr ()
  (interactive)
  (slime-repl-previous-input)
  (paredit-backward)
  (paredit-wrap-sexp))
(global-set-key [(control x) (w)]  'change-pr)

;;; font
(set-default-font "文泉驿等宽微米黑-11")
;(set-face-attribute 'default nil :font "文泉驿等宽正黑-12") ; very good width
(set-face-attribute 'default nil :font "文泉驿等宽微米黑-11") ; very good width
;(set-face-attribute 'default nil :font "Monaco-12")  ; good for programming
;(set-face-attribute 'default nil :height 120)
                                        ; The value is in 1/10pt, so 100 will give you 10pt, etc.
;;; org export to html, no sub-superscripts
(eval-after-load 'org
  '(progn
     (define-key global-map "\C-cc" 'org-capture)
     (setq org-default-notes-file (concat org-directory "/tasks.org"))

     (setq org-capture-templates
           '(("t" "Todo" entry (file+datetree "~/org/gtd.org")
              "* TODO [#%^{property|B|A|C}]  %?\n  %i\n")
             ("w" "Waiting" entry (file+datetree "~/org/gtd.org")
              "* WAITING [#%^{property|B|A|C}]  %?\n %^t\n %i\n")
             ("i" "Idea/someday" entry (file+datetree "~/org/gtd.org")
              "* SOMEDAY [#C] %?\n")
             ("h" "Hadoop" entry (file+headline "~/org/journal.org" "hadoop")
              "* %? \n %U\n %i\n")
             ("b" "Hbase" entry (file+headline "~/org/journal.org" "hbase")
              "* %? \n %U\n %i\n")
             ("l" "Linux" entry (file+headline "~/org/journal.org" "linux")
              "* %? \n %U\n %i\n")
             ("r" "RabbitMQ" entry (file+headline "~/org/journal.org" "rabbitMQ")
              "* %? \n %U\n %i\n")
             ("s" "LISP" entry (file+headline "~/org/journal.org" "lisp")
              "* %? \n %U\n %i\n")
             ("e" "Emacs" entry (file+headline "~/org/journal.org" "emacs")
              "* %? \n %U\n %i\n")
             ("m" "misc" entry (file+headline "~/org/journal.org" "misc")
              "* %? %^g\n %U\n %i\n")))

     ;; only use file::linenumber link to exactly go to where I want, change from
     ;; http://lists.gnu.org/archive/html/emacs-orgmode/2012-02/msg00706.html
     (defun org-file-lineno-store-link()
       (let* ((link (format "file:%s::%d" (buffer-file-name) 
                            (line-number-at-pos))))
         (org-store-link-props
          :type "file"
          :link link)))
     (setq org-store-link-functions (list 'org-file-lineno-store-link))
     (defun lineno-goto (open-store-arg)
       (message "length:%s" open-store-arg)
       (goto-line (string-to-int open-store-arg)))
     ;; use the same simple line goto function
     (setq org-execute-file-search-functions (list 'lineno-goto))
     ;; end lineno hack

     (setq org-use-sub-superscripts nil)
     (setq org-export-with-toc nil)))

(setq org-agenda-files (list "/home/wizard/org"))
(setq org-return-follows-link t)


;;; rebind
(global-set-key [(control s)] '(lambda ()
                                 "For easy search, eg C-s C-w"
                                 (interactive)
                                 (backward-word)
                                 (isearch-forward)))
(global-set-key [(f5)] 'query-replace-regexp)
(global-set-key [(f8)] 'magit-status)
(global-set-key [(control f8)] 'magit-log)


(setq hippie-expand-try-functions-list
      '(
        try-expand-dabbrev
        try-expand-dabbrev-visible
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-expand-list
        try-expand-list-all-buffers
        try-expand-line-all-buffers
        try-expand-line
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol
        try-expand-whole-kill
        senator-try-expand-semantic
;;;         senator-complete-symbol
;;;         semantic-ia-complete-symbol
        ispell-complete-word))
(global-set-key [(control tab)] 'hippie-expand) ;hippie-expand is very good 


;;; for scheme
(setq scheme-program-name "larceny")
;;; for auto-complete
