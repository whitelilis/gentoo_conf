;;;; docbookide.el --- DocBook Integrated Development Environment
;; $Id: docbookide.el,v 1.1.1.1 2000/03/29 18:57:00 nwalsh Exp $

;; Copyright (C) 2000 Norman Walsh
;; Based extensively on (one might go so far as to say "totally hacked
;; from") Tony Graham's xslide.

;; Author: Norman Walsh <ndw@nwalsh.com>
;; Created: 29 March 2000
;; Version: $Revision: 1.1.1.1 $
;; Keywords: languages, xml, docbook

;;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


;;;; Commentary:

;; Functions for editing DocBook documents

;; Requires dbide-font.el
;; Requires 'etags for `find-tag-default'
;; Requires 'reporter for `docbook-submit-bug-report'
;;
;; Send bugs to docbookide-bug@nwalsh.com
;; Use `docbook-submit-bug-report' for bug reports

;;;; Code:
(provide 'docbookide)

(require 'cl)
(require 'compile)
(require 'font-lock)
;; We need etags for `find-tag-default'
(require 'etags)

(require 'dbide-data "dbide-data")
(require 'dbide-abbrev "dbide-abbrev")
(require 'dbide-font "dbide-font")
(require 'dbide-process "dbide-process")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version information

(defconst docbookide-version "0.1"
  "Version number of docbookide.")

(defun docbookide-version ()
  "Returns the value of the variable docbookide-version."
  docbookide-version)

(defconst docbookide-maintainer-address "docbookide-bug@nwalsh.com")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables

(defvar docbook-default-filespec "*.xml"
  "*Inital prompt value for `docbook-etags''s FILESPEC argument.")

(defvar docbook-filespec-history (list docbook-default-filespec)
  "Minibuffer history list for `docbook-etags' and `docbook-grep''s FILESPEC argument.")

(defvar docbook-grep-pattern-history nil
  "Minibuffer history list for `docbook-grep''s PATTERN argument.")

(defvar docbook-grep-case-sensitive-flag nil
  "*Non-nil disables case insensitive searches by `docbook-grep'.")

(defvar docbook-comment-start "<!--"
  "*Comment start character sequence")

(defvar docbook-comment-end "-->"
  "*Comment end character sequence")

(defvar docbook-comment-max-column 70
  "*Maximum column number for text in a comment")

;; DOCBOOKIDE house style puts all comments starting on a favourite column
(defun docbook-comment (comment)
  "Insert COMMENT starting at the usual column.

With a prefix argument, e.g. \\[universal-argument] \\[docbook-comment], insert separator comment
lines above and below COMMENT in the manner of `docbook-big-comment'."
  (interactive "sComment: ")
  (insert "\n")
  (backward-char)
  (let ((fill-column (1- docbook-comment-max-column))
	(fill-prefix (make-string (1+ (length docbook-comment-start)) ?\ ))
;;	(comment-start docbook-init-comment-fill-prefix)
	(saved-auto-fill-function auto-fill-function))
    (auto-fill-mode 1)
    (insert docbook-comment-start)
    (indent-to (length fill-prefix))
    (fill-region (point) (save-excursion
			   (insert comment)
			   (point))
		 nil
		 1
		 1)
    ;; The fill does the right thing, but it always ends with
    ;; an extra newline, so we delete the newline.
    (delete-backward-char 1)
    (if (not saved-auto-fill-function)
	(auto-fill-mode 0))
    (insert " ")
    (insert docbook-comment-end)
    (insert "\n")
    (if font-lock-mode
	(save-excursion
	  (font-lock-fontify-keywords-region
	   (docbook-font-lock-region-point-min)
	   (docbook-font-lock-region-point-max))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mode map stuff

(defvar docbook-mode-map nil
  "Keymap for DOCBOOK mode.")

(defvar docbook-context-tab nil
  "Toggle automatic tabbing behavior.")

(if docbook-mode-map
    ()
  (setq docbook-mode-map (make-sparse-keymap))
  (define-key docbook-mode-map [(control c) tab]	  'docbook-force-electric-tab)
  (define-key docbook-mode-map [tab]	  'docbook-complete)
  (define-key docbook-mode-map "\""   	  'docbook-electric-quote)
  (define-key docbook-mode-map "'"   	  'docbook-electric-apos)
  (define-key docbook-mode-map "/"   	  'docbook-electric-slash)
  (define-key docbook-mode-map "<"   	  'docbook-electric-less-than)
  (define-key docbook-mode-map "["   	  'docbook-electric-lsqb)
  (define-key docbook-mode-map "("   	  'docbook-electric-lpar)
  (define-key docbook-mode-map "{"   	  'docbook-electric-lcub)
  (define-key docbook-mode-map [(control c) (control p)]
				   	  'docbook-process)
  (define-key docbook-mode-map "\C-c<"    'docbook-insert-tag)
  (define-key docbook-mode-map "\177"	  'backward-delete-char-untabify)
)

(defun docbook-electric-apos ()
  "Function called when \"'\" is pressed in DOCBOOK mode"
  (interactive)
  (insert "'")
  (if (looking-at "\\([\"/})]\\|$\\)")
      (save-excursion
	(insert "'"))))

(defun docbook-electric-quote ()
  "Function called when '\"' is pressed in DOCBOOK mode"
  (interactive)
  (insert "\"")
  (if (looking-at "\\(['/})]\\|$\\)")
      (save-excursion
	(insert "\""))))

(defun docbook-electric-lsqb ()
  "Function called when \"[\" is pressed in DOCBOOK mode"
  (interactive)
  (insert "[")
  (if (looking-at "\\([\"'/})]\\|$\\)")
      (save-excursion
	(insert "]"))))

(defun docbook-electric-lpar ()
  "Function called when \"(\" is pressed in DOCBOOK mode"
  (interactive)
  (insert "(")
  (if (looking-at "\\([\]\"'/}]\\|$\\)")
      (save-excursion
	(insert ")"))))

(defun docbook-electric-lcub ()
  "Function called when \"{\" is pressed in DOCBOOK mode"
  (interactive)
  (insert "{")
  (if (looking-at "\\([\])\"'/}]\\|$\\)")
      (save-excursion
	(insert "}"))))

(defun docbook-electric-less-than ()
  "Function called when \"<\" is pressed in DOCBOOK mode"
  (interactive)
  (insert "<")
  (docbook-electric-tab))

(defun docbook-electric-slash ()
  "Function called when \"/\" is pressed in DOCBOOK mode"
  (interactive)
  (insert "/")
  (docbook-electric-tab)
  (if (looking-at "$")
      (let ((element-name
	     (save-excursion
	       (backward-char 2)
	       (if (looking-at "</")
		   (catch 'start-tag
		     (while (re-search-backward "<" nil t)
		       (cond
			((looking-at "</\\([^/> \t]+\\)>")
;;			 (message "End tag: %s" (match-string 1))
			 (re-search-backward
			  (concat "<" (match-string 1) "[ \t\n\r>]") nil t))
			((looking-at "<\\(\\([^/>]\\|/[^>]\\)+\\)/>"))
;;			 (message "Empty tag: %s" (match-string 1)))
			((looking-at "<!--[^-]*\\(-[^-]+\\)*-->"))
			((looking-at "<\\([^/> \t]+\\)")
;;			 (message "Start tag: %s" (match-string 1))
			 (throw 'start-tag (match-string 1)))
			((bobp)
			 (throw 'start-tag nil)))))
		 nil))))
	(if element-name
	    (insert (concat element-name ">"))))))


(defun docbook-electric-return ()
  (interactive)
  (insert "\n")
  (docbook-electric-tab))

(defun docbook-electric-tab ()
  (interactive)
  (if docbook-context-tab
      (docbook-force-electric-tab)))

(defun docbook-force-electric-tab ()
  "Function called when TAB is pressed in DOCBOOK mode."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (delete-horizontal-space)
    (if (looking-at "</")
	(indent-to (max 0 (- (docbook-calculate-indent) 2)))
      (indent-to (docbook-calculate-indent))))
  (if (and
       (bolp)
       (looking-at "[ \t]+"))
      (goto-char (match-end 0))))

(defun docbook-calculate-indent ()
  "Calculate what the indent should be for the current line"
  (interactive)
  (save-excursion
    (if (re-search-backward "^\\([ \t]*\\)<" nil t)
	(goto-char (match-end 1))
      (beginning-of-line))
    (if (or 
	 (save-excursion
	   (re-search-forward "\\(</[^<>]+>\\|<[^/][^<>]+/>\\)[ \t]*$"
			      (save-excursion (end-of-line) (1+ (point)))
			      t))
	 (bobp))
	(current-column)
      (+ (current-column) 2))))

(defun docbook-complete ()
  "Complete the tag or attribute before point.
If it is a tag (starts with < or </) complete with allowed tags,
otherwise complete with allowed attributes."
  (interactive "*")
  (let ((tab				; The completion table
	 nil)
	(pattern nil)
	(c nil)
	(here (point))
	(prev-oab (point))
	(prev-cab (point))
	(start-tag nil))
    (setq prev-oab (search-backward "<" nil t nil))
    (if (looking-at "<\\([^/> \t]+\\)")
	(setq start-tag (match-string 1)))
    (goto-char here) ;; move back from where the searches moved us...
    (setq prev-cab (search-backward ">" nil t nil))
    (goto-char here) ;; move back from where the searches moved us...
    (skip-chars-backward "^ \n\t</!&%")
    (setq pattern (buffer-substring (point) here))
    (setq c (char-after (1- (point))))
;    (message (format "c = %s (%s)" c start-tag))
;    (message (format "oab: %d cab: %d" prev-oab prev-cab))
;    (if (and (eq c ? ) (> prev-oab prev-cab))
;	(message "and is true")
;      (message "and is false"))
    (cond
     ;; start-tag
     ((eq c ?<)
      (setq tab docbook-all-elements-alist))
     ;; attribute (we're only on an attribute if the thing before this
     ;; word is a space and we're inside < and >. Then only let the
     ;; attributes allowed on a given element to be possible completions.
     ;; If we can't figure out what's allowed, let all the attributes
     ;; be the completion.
     ((and (eq c ? ) (> prev-oab prev-cab))
      (if start-tag
	  (let* ((eleminfo (assoc start-tag docbook-all-elements-alist))
		 (attrs    (if eleminfo
			       (nth 2 eleminfo)
			     nil)))
	    (if attrs
		(setq tab (mapcar (lambda (x)
				    (list x x nil))
				  attrs))
	      (setq tab docbook-all-attribute-alist)))
	(setq tab docbook-all-attribute-alist)))
     (t
      (goto-char here)
      (ispell-complete-word)))
    (when tab
      (let ((completion (try-completion pattern tab)))
	(cond ((null completion)
	       (goto-char here)
	       (message "Can't find completion for \"%s\"" pattern)
	       (ding))
	      ((eq completion t)
	       (goto-char here)
	       (message "[Complete]"))
	      ((not (string= pattern completion))
	       (delete-char (length pattern))
	       (insert completion))
	      (t
	       (goto-char here)
	       (message "Making completion list...")
	       (let ((list (all-completions pattern tab)))
		 (with-output-to-temp-buffer " *Completions*"
		   (display-completion-list list)))
	       (message "Making completion list...%s" "done")))))))

(defun docbook-insert-tag (tag)
  "Insert a tag, reading tag name in minibuffer with completion."
  (interactive
   (list
    (completing-read "Tag: " docbook-all-elements-alist)))
  ;;  (docbook-find-context-of (point))
  ;;  (assert (null docbook-markup-type))
  ;; Fix white-space before tag
  ;;  (unless (docbook-element-data-p (docbook-parse-to-here))
  (skip-chars-backward " \t")
  (cond
   ((looking-at "^\\s-*$")
    (docbook-electric-tab))
   ((looking-at "^\\s-*</")
    (save-excursion
      (insert "\n"))
    (docbook-electric-tab))
   ((looking-at "$")
    (insert "\n")
    (docbook-electric-tab)))
  (let ((tag-type (nth 1 (assoc tag docbook-all-elements-alist))))
    (cond
     ((equal tag-type "block")
      (insert "<")
      (insert tag)
      (insert ">")
      (save-excursion
	(insert "\n")
	(docbook-electric-tab)
	(insert "<")
	(if (looking-at "<")
	    (progn
	      (insert "\n")
	      (backward-char)))
	(docbook-electric-slash)))
     ((equal tag-type "inline")
      (insert "<")
      (insert tag)
      (insert ">")
      (save-excursion
	(insert "</")
	(insert tag)
	(insert ">")))
     (t
      (insert "<")
      (insert tag)
      (save-excursion
	(insert "/>")))))

  (let ((here (point))
	(auto-insert (assoc tag docbook-all-autoinsert-alist)))
    (if auto-insert
	(progn
	  (insert (car (cdr auto-insert)))
	  (goto-char here)
	  (if (search-forward "^" nil t nil)
	      (if (> (- (point) here) (length (car (cdr auto-insert))))
		  (goto-char here)
		(progn
		  (forward-char -1)
		  (delete-char 1)))
	    (goto-char here))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax table stuff

(defvar docbook-mode-syntax-table nil
  "Syntax table used while in DOCBOOK mode.")

(if docbook-mode-syntax-table
    ()
  (setq docbook-mode-syntax-table (make-syntax-table))
  ;; set the non-alphanumeric characters in XML names to
  ;; 'symbol constituent' class
  (modify-syntax-entry ?: "_" docbook-mode-syntax-table)
  (modify-syntax-entry ?_ "_" docbook-mode-syntax-table)
  (modify-syntax-entry ?- "_ 1234" docbook-mode-syntax-table)
  (modify-syntax-entry ?. "_" docbook-mode-syntax-table)
  ;; "-" is a special case because it is the first and second characters
  ;; of the start- and end-comment sequences.
  (modify-syntax-entry ?- "_ 1234" docbook-mode-syntax-table)
  ;; "%" does double duty in parameter entity declarations and references.
  ;; Not necessary to make "%" and ";" act like parentheses since the
  ;; font lock highlighting tells you when you've put the ";" on the
  ;; end of a parameter entity reference.
  (modify-syntax-entry ?% "_" docbook-mode-syntax-table)
  (modify-syntax-entry ?\; "_" docbook-mode-syntax-table)
  ;; "/" is just punctuation in DOCBOOKs, and really only has a role in
  ;; Formal Public Identifiers
  (modify-syntax-entry ?/ "." docbook-mode-syntax-table)
  ;; Sometimes a string is more than just a string, Dr Freud.
  ;; Unfortunately, the syntax stuff isn't fussy about matching
  ;; on paired delimeters, and will happily match a single quote
  ;; with a double quote, and vice versa.  At least the font
  ;; lock stuff is more fussy and won't change colour if the
  ;; delimiters aren't paired.
  (modify-syntax-entry ?\" "$" docbook-mode-syntax-table)
  (modify-syntax-entry ?\' "$" docbook-mode-syntax-table)
  ;; The occurrence indicators and connectors are punctuation to us.
  (modify-syntax-entry ?| "." docbook-mode-syntax-table)
  (modify-syntax-entry ?, "." docbook-mode-syntax-table)
  (modify-syntax-entry ?& "." docbook-mode-syntax-table)
  (modify-syntax-entry ?? "." docbook-mode-syntax-table)
  (modify-syntax-entry ?+ "." docbook-mode-syntax-table)
  (modify-syntax-entry ?* "." docbook-mode-syntax-table)
  ;; `<' and `>' are also punctuation
  (modify-syntax-entry ?< "." docbook-mode-syntax-table)
  (modify-syntax-entry ?> "." docbook-mode-syntax-table)
  ;; "#" is syntax too
  (modify-syntax-entry ?# "_" docbook-mode-syntax-table))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; grep stuff

;;;###autoload
(defun docbook-grep (pattern filespec)
  "Grep for PATTERN in files matching FILESPEC.

Runs `grep' with PATTERN and FILESPEC as arguments.

PATTERN is the pattern on which `grep' is to match.  PATTERN is quoted
with single quotes in the `grep' command arguments to avoid
interpretation of characters in PATTERN.  `docbook-grep' maintains a
history of PATTERNs so you can easily re-use a previous value.

FILESPEC is the names or regular expression for the files to be
scanned by grep.  Since `docbook-grep' uses `grep', regular expressions
and multiple filenames are supported, and \"*.docbook\" and \"*.DOCBOOK
*.ent\" are both valid FILESPEC values.

When called interactively, the initial FILESPEC is taken from
docbook-default-filespec, but `docbook-grep' also maintains a history of
FILESPEC arguments so you can easily re-use a previous value.  The
history is shared with `docbook-etags' so you can re-use the same FILESPEC
with both functions.
"
  (interactive
   (list
    (docbook-read-from-minibuffer "Pattern: "
			      (find-tag-default)
			      'docbook-grep-pattern-history)
    (docbook-read-from-minibuffer "Files: "
			      (car docbook-filespec-history)
			      'docbook-filespec-history)))
  ;; We include "--" in the command in case the pattern starts with "-"
  (grep (format "grep -n %s -- '%s' %s"
		(if (not docbook-grep-case-sensitive-flag)
		    "-i")
		pattern
		filespec)))


;;;###autoload
(defun docbook-mode ()
  "Major mode for editing DOCBOOK stylesheets.

Special commands:
\\{docbook-mode-map}
Turning on DOCBOOK mode calls the value of the variable `docbook-mode-hook',
if that value is non-nil.

Abbreviations:

DOCBOOK mode includes a comprehensive set of DOCBOOK-specific abbreviations
preloaded into the abbreviations table.

Font lock mode:

Turning on font lock mode causes various DOCBOOK syntactic structures to be 
hightlighted. To turn this on whenever you visit an DOCBOOK file, add
the following to your .emacs file:
  \(add-hook 'docbook-mode-hook 'turn-on-font-lock\)
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map docbook-mode-map)
  (setq mode-name "DOCBOOK")
  (setq major-mode 'docbook-mode)
  (setq local-abbrev-table docbook-mode-abbrev-table)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(docbook-font-lock-keywords t))
  (setq font-lock-mark-block-function 'docbook-font-lock-mark-block-function)
  (set-syntax-table docbook-mode-syntax-table)
  (run-hooks 'docbook-mode-hook))


;;;; Bug reporting

(eval-and-compile
  (autoload 'reporter-submit-bug-report "reporter"))

(defun docbook-submit-bug-report ()
  "Submit via mail a bug report on DOCBOOKIDE."
  (interactive)
  (and (y-or-n-p "Do you really want to submit a report on DOCBOOK mode? ")
       (reporter-submit-bug-report
	docbookide-maintainer-address
	(concat "docbookide.el " docbookide-version)
	(list 
	 )
	nil
	nil
     "Please change the Subject header to a concise bug description.\nRemember to cover the basics, that is, what you expected to\nhappen and what in fact did happen.  Please remove these\ninstructions from your message.")
    (save-excursion
      (goto-char (point-min))
      (mail-position-on-field "Subject")
      (beginning-of-line)
      (delete-region (point) (progn (forward-line) (point)))
      (insert
       "Subject: DOCBOOKIDE version " docbookide-version " is wonderful but...\n"))))


;;;; Last provisions
;;;(provide 'docbookide)

;;; docbookide.el ends here
