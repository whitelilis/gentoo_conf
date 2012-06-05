;(add-hook 'gnuserv-visit-hook '(lambda ()
;                                 (local-set-key [(control c) (control c)]
;                                                (lambda ()
;                                                  (interactive)
;                                                  (save-buffer)
;                                                  (gnuserv-edit)))))
;

(add-hook 'server-switch-hook
            (lambda ()
              (when (current-local-map)
                (use-local-map (copy-keymap (current-local-map))))
              (when server-buffer-clients
                (local-set-key [(control c) (control c)] 'server-edit))))
