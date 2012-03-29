;; nxml autoload

(load "rng-auto.el")
(setq auto-mode-alist
        (cons '("\\.\\(xml\\|xsl\\|rng\\|xhtml\\|html\\)\\'" . nxml-mode)
              auto-mode-alist))
(setq nxml-slash-auto-complete-flag t)
