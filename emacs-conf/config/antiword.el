(add-to-list 'auto-mode-alist '("\\.doc\\'" . no-word))

(defun no-word ()
  "Run antiword on the entire buffer."
  (shell-command-on-region (point-min) (point-max) "antiword - " t t))
