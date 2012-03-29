;; my key binding
;; f1 f2 f3 f4 for fvwm

;; use org-mode , the follow two lines not useful now.
;; (global-set-key [f5] 'planner-create-task)
;; (global-set-key [(C-f5)] 'planner-create-task-from-buffer)

(global-set-key [(control f5)] 'query-replace-regexp) ; it is so useful that I bind it here

(global-set-key [(control f6)] 'man)
;(global-set-key [(f7)] 'flyspell-buffer)
;(global-set-key [(C-f7)] 'flyspell-region)
;(global-set-key [(f8)] 'compile)
(global-set-key [(f10)] 'remember)
;; (global-set-key [(C-f9)] 'wizard-indent-remember)
(global-set-key [(f11)] 'hide-subtree)
(global-set-key [(f12)] 'show-subtree)

(define-key global-map [(f5)]  'cscope-find-this-symbol)
(define-key global-map [(f6)]  'cscope-find-global-definition)
(define-key global-map [(f7)]  'cscope-find-called-functions)
(define-key global-map [(f8)]  'cscope-find-functions-calling-this-function)



;(global-set-key [(control tab)] 'senator-complete-symbol)
(global-set-key [(control tab)] 'hippie-expand) ;hippie-expand is very good (define the list in ~/emacs-config/conf/var.el)
(global-set-key [(M-u)] 'wizard-back-upcase)
(global-set-key [(S-tab)] 'ispell-complete-word)
(global-set-key [(shift space)] 'set-mark-command)
;; I'd like to use only one key to comment or uncomment region
;; but the function comment-or-uncomment-region work wrong in C-mode(work right in docbook mode), so I have to use two bindings
;; now I know that the comment-dwim command  which binded to M-; works well as I think ,and it do more than I thought.
;; (global-set-key [(control c)(control c)] 'comment-dwim) ; over ride with "comment-region" by C-mode

;; my functions binding to C-c C-w \some; for wizard or whitelilis or wqy or so on
(global-set-key [(control c)(control w)(control t)] 'wizard-insert-current-time)
(global-set-key [(control c)(control f)] 'wizard-insert-function-comment)
;(global-set-key [(control c)(control w) d] 'wizard-indent-remember)

;; for effective emacs
(global-set-key "\C-w" 'wizard-kill-backward-word-or-region)
(global-set-key [(C-down-mouse-1)] 'flyspell-correct-word)
