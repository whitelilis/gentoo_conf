;; mmm-mode
(require 'mmm-mode)
(require 'mmm-auto)
(setq mmm-global-mode 'maybe)
;(mmm-add-mode-ext-class MODE EXTENSION CLASS)
(mmm-add-mode-ext-class nil "\\.jsp\\'" 'jsp )
(mmm-add-mode-ext-class nil "\\.php\\'" 'html-php)
;(mmm-add-mode-ext-class 'html-mode nil 'mason)
(setq  mmm-submode-decoration-level 2)  ;0,1 or 2


;; for RoR .html.erb file
;; (set-face-background 'mmm-output-submode-face  "LightGrey")
;; (set-face-background 'mmm-code-submode-face    "MediumSlateBlue")
;; (set-face-background 'mmm-comment-submode-face "MediumOliveGreen")

(mmm-add-classes
 '((erb-code
    :submode ruby-mode
    :match-face (("<%#" . mmm-comment-submode-face)
                 ("<%=" . mmm-output-submode-face)
                 ("<%"  . mmm-code-submode-face))
    :front "<%[#=]?"
    :back "-?%>"
    :insert ((?% erb-code       nil @ "<%"  @ " " _ " " @ "%>" @)
             (?# erb-comment    nil @ "<%#" @ " " _ " " @ "%>" @)
             (?= erb-expression nil @ "<%=" @ " " _ " " @ "%>" @))
    )))
(add-hook 'nxml-mode-hook
          (lambda ()
            (setq mmm-classes '(erb-code))
            (mmm-mode-on)))
(add-to-list 'auto-mode-alist '("\\.html.erb$" . nxml-mode))
