;;; wizard-fun.el ---

;; Copyright 2007 LiuZhe
;;
;; Author: whitelilis@gmail.com
;; Version: $Id: TEMPLATE.el.tpl,v 1.1.1.1 2007/03/10 10:05:55 wizard Exp $

(defun wizard-insert-current-time()
  "Insert current time."
  (interactive)
  (save-excursion)
  (insert (current-time-string))
  )

(defun wizard-indent-remember()
  "Indent remember text format."
  (interactive)
  (save-excursion)
  (beginning-of-buffer)
  (next-line)
  (replace-regexp "^" "\t")
  (mark-whole-buffer)
  (remember-region)
  )

(defun wizard-ror-shells()
  "Ruby on Rails use many shells."
  (interactive)
  (save-excursion)
;;  (shell "command-shell")
  (shell "ruby-shell")
;;  (shell "console-shell")
  (shell "migrate-shell")
;;  (shell "test-shell")
  )

(defun wizard-back-upcase()
  "Move backward word and upcase the current word."
  (backward-word)
  (upcase-word)
)
(defun wizard-kill-backward-word-or-region(arg)
  "If region is active, kill region; else kill backward word."
  (interactive "p")
  (if (not (c-region-is-active-p))
      (kill-word (- arg))
    (kill-region (region-beginning) (region-end))
    )
  )
(defun wizard-new-brace-binding()
  (interactive)
  (self-insert-command 1)
  (newline-and-indent)
)
;; (define-key java-mode-map [({)] 'wizard-new-brace-binding)
;; (define-key java-mode-map [(\;)] 'wizard-new-brace-binding)

(defun wizard-chinese-insert-math()
  (interactive)
  (insert "~$$~")
  (backward-char 2)
  )

(defun wizard-insert-function-comment(arg)
  (interactive "*P")
  (let( (content '("contract" "commnets" "success" "fail" "samples"))
        (comment-header ": ")
        (point-to-move 0)
        )
    (save-excursion
      (dolist (item content)
        (align-newline-and-indent)
        (comment-dwim arg)
        (insert " ")
        (insert item)
        (tab-to-tab-stop)
        (insert comment-header)
        (move-end-of-line arg)
        )
      ;; (previous-line 2)
      )
    (move-beginning-of-line 2)                ;move point to next( 2 - 1 = 1) line first
    (isearch-forward ":")
    (forward-char (length comment-header)) ;move point to the end of comment-header
    )
  )
(defun wizard-indent-or-complete()
  (interactive)
  (if (looking-at "\\>")
      (hippie-expand nil)
    (indent-for-tab-command))
  )



;; Toggle window dedication

(defun toggle-window-dedicated ()
"Toggle whether the current active window is dedicated or not"
(interactive)
(message
 (if (let (window (get-buffer-window (current-buffer)))
       (set-window-dedicated-p window
        (not (window-dedicated-p window))))
    "Window '%s' is dedicated"
    "Window '%s' is normal")
 (current-buffer)))


;;; wizard-fun.el ends here
