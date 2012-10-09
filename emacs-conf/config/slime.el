(setq inferior-lisp-program "/usr/local/bin/sbcl")
;(setq inferior-lisp-program "/opt/cmucl/bin/lisp")
;(setq inferior-lisp-program "/usr/local/bin/sbcl --core /usr/local/lib64/sbcl/sbcl.core")
;(setq inferior-lisp-program "/usr/bin/sbcl --core /home/wizard/src/logs/LoGS-sbcl.core")
;(setq inferior-lisp-program "/usr/bin/ccl -K UTF-8 -I /home/wizard/tmp/cl-http/cl-http-70-218-s436-binghe-r75/contrib/kpoeck/port-template/cl-http.image")
;(setq inferior-lisp-program "/usr/bin/ccl -K UTF-8")
;(setq inferior-lisp-program "/usr/bin/ccl")
;(setq inferior-lisp-program "/usr/bin/ccl -n -I /home/wizard/src/lisp/res.image")
;(setq inferior-lisp-program "/home/wizard/src/ccl-1.7/lx86cl64")
(require 'slime)
(slime-setup '(slime-fancy slime-xref-browser))
;(add-to-list 'auto-mode-alist '(".cl" . common-lisp-mode))
(setq slime-net-coding-system 'utf-8-unix)
;(setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)
(setq common-lisp-hyperspec-root "/usr/share/doc/hyperspec-7.0-r2/HyperSpec/")
(setq swank:*globally-redirect-io* t)


; key bindings

(global-set-key "\C-cs" 'slime-selector)

(defun my-indent-or-complete ()
  " hippie-expand indent"
  (interactive)
  (if (looking-at "\\>")
      (slime-complete-symbol)
    (indent-for-tab-command)
    ))

; paredit mode
;(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)

; for complete
(define-key lisp-mode-map [(tab)]
  'slime-indent-and-complete-symbol)

; for auto slime
(add-hook 'slime-mode-hook
          (lambda ()
;            (paredit-mode +1)
            (unless (slime-connected-p)
              (save-excursion (slime)))))


;(add-hook 'slime-repl-mode-hook (lambda () (enable-paredit-mode)))


; for shortcut
(defslime-repl-shortcut nil  ("processes")
  (:handler 'slime-list-threads))
