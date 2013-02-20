(autoload 'enable-paredit-mode "paredit"
     "Turn on pseudo-structural editing of Lisp code."
     t)
(setq inferior-lisp-program "/usr/local/bin/sbcl")
;(setq inferior-lisp-program "/opt/cmucl/bin/lisp")
;(setq inferior-lisp-program "/usr/local/bin/sbcl --core /usr/local/lib64/sbcl/sbcl.core")
;(setq inferior-lisp-program "/usr/bin/sbcl --core /home/wizard/src/logs/LoGS-sbcl.core")
;(setq inferior-lisp-program "/usr/bin/ccl -K UTF-8 -I /home/wizard/tmp/cl-http/cl-http-70-218-s436-binghe-r75/contrib/kpoeck/port-template/cl-http.image")
;(setq inferior-lisp-program "/usr/bin/ccl -K UTF-8")
;(setq inferior-lisp-program "/usr/bin/ccl")
;(setq inferior-lisp-program "/usr/bin/ccl -n -I /home/wizard/src/lisp/res.image")
;(setq inferior-lisp-program "/home/wizard/src/ccl-1.7/lx86cl64")

(require 'rainbow-delimiters)
(global-rainbow-delimiters-mode)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(completions-common-part ((t (:inherit default :foreground "red"))))
 '(diredp-compressed-file-suffix ((t (:foreground "#7b68ee"))))
 '(diredp-ignored-file-name ((t (:foreground "#aaaaaa"))))

 '(rainbow-delimiters-depth-1-face ((t (:foreground "#f00050"))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#005000"))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#500000"))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#0000b0"))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#00b000"))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#b00000"))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#0000f0"))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "#00f000"))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "#f00000"))))
 '(rainbow-delimiters-unmatched-face ((t (:foreground "red"))))
 '(show-paren-match ((((class color) (background light)) (:background "azure2")))))




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
            (enable-paredit-mode)
            (unless (slime-connected-p)
              (save-excursion (slime)))))


(add-hook 'slime-repl-mode-hook (lambda () (enable-paredit-mode)))


; for shortcut
(defslime-repl-shortcut nil  ("processes")
  (:handler 'slime-list-threads))
