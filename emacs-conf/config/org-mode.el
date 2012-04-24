
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Org Mode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-agenda-files (list "~/org/notes.org"))

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

;;(define-prefix-command 'org-mode-map)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)

(setq org-log-done '(done))


;; OrgMode & Remember

(setq org-directory "~/org")
(setq org-default-notes-file "~/org/notes.org")
(setq remember-annotation-functions '(org-remember-annotation))
(setq remember-handler-functions '(org-remember-handler))
(add-hook 'remember-mode-hook 'org-remember-apply-template)

(setq org-remember-templates
      '(
        ("Project" ?p "* %U %? %^g\n\n"           "~/org/notes.org" "Projects")
        ("Project" ?P "* %U %? %^g\n\n  %a\n"     "~/org/notes.org" "Projects")
        ("Todo"    ?t "* TODO %? %^g\n\n"         "~/org/notes.org" "Next Actions")
        ("Todo"    ?T "* TODO %? %^g\n\n  %a\n\n" "~/org/notes.org" "Next Actions")
        ("Journal" ?j "* %U %^g\n  %?\n"          "~/org/notes.org" "Journal")
        ("Journal" ?J "* %U %^g\n  %?\n  %a\n"    "~/org/notes.org" "Journal")
        ("Idea"    ?i "* %U %?\n\n"               "~/org/notes.org" "SomeDay/Maybe")
        ("Idea"    ?I "* %U %?\n\n  %a\n"         "~/org/notes.org" "SomeDay/Maybe")
        ("Waiting" ?w "* %U %? %^g\n\n"           "~/org/notes.org" "Waiting For")
        ("Waiting" ?W "* %U %? %^g\n\n  %a\n"     "~/org/notes.org" "Waiting For")
        ("Dairy"   ?d "* %U \n  %?"               "~/org/notes.org" "Dairy")
        ("Dairy"   ?D "* %U \n  %?  %a\n"         "~/org/notes.org" "Dairy")
        ))

;; org project

(setq org-publish-project-alist
      '(("org"
         :base-directory "~/org"
         :publishing-directory "~/org/public_html"
         :section-numbers nil
         :table-of-contents nil
         :style "<link rel=stylesheet
href=\"mystyle.css\"
type=\"text/css\">")))

;; open appt message function

(appt-activate t)

(setq appt-display-format 'window)

(add-hook 'diary-hook 'appt-make-list)



;; org to appt

(setq appt-display-duration 30)
(setq appt-audible t)
(setq appt-display-mode-line t)

;;(appt-activate 1)

(setq appt-msg-countdown-list '(10 0))
;;(org-agenda-list)
(org-todo-list 1)
(delete-other-windows)
(org-agenda-to-appt)


;(define-key org-mode-map [(C-return)] 'org-insert-todo-heading)
(define-key org-mode-map [(C-tab)] 'hippie-expand)
(define-key org-mode-map [(S-tab)] 'org-force-cycle-archived)
(define-key org-mode-map [(f9)] 'remember)
;; strange , in org mode ,this must turn  manually, the follow line doesn't work
;; (add-hook 'org-mode-hook 'toggle-truncate-lines)

;;org export
(setq org-export-with-sub-superscripts nil)
