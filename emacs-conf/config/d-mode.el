(autoload 'd-mode "d-mode" () t)
(add-to-list 'auto-mode-alist '("\\.d\\'" . d-mode))
(add-hook 'd-mode-hook 'imenu-add-menubar-index)
(add-hook 'd-mode-hook 'font-lock-mode)
