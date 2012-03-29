(require 'rails)
;; rails-minor-mode define the key f9 to 'svn-status, not useful for me, and I like it binds to 'remember
(define-key rails-minor-mode-map [(f9)] 'remember)
(define-key rails-minor-mode-map [(tab)] 'c-indent-line-or-region)

