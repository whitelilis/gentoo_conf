;; load the fvwm-mode so we can use it
(load "fvwm-mode")

;; Automatically load fvwm mode for fvwm configuration files
(setq auto-mode-alist
      (cons '("FvwmApplet-" . fvwm-mode)
            (cons '("FvwmScript-" . fvwm-mode)
                  (cons '("\\.fvwm2rc$\\|\\.fvwmrc$" . fvwm-mode)
                        auto-mode-alist))))
