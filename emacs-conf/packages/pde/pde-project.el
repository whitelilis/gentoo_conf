;;; pde-project.el --- Project management for Perl

;; Copyright (C) 2007 Free Software Foundation, Inc.
;;
;; Author: Ye Wenbin <wenbinye@gmail.com>
;; Maintainer: Ye Wenbin <wenbinye@gmail.com>
;; Created: 24 Dec 2007
;; Version: 0.01
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; 

;; Put this file into your load-path and the following into your ~/.emacs:
;;   (require 'pde-project)

;;; Code:

(eval-when-compile
  (require 'cl))
(require 'pde-vars)

(defgroup pde-project nil
  "Pde project"
  :group 'pde)

(defcustom pde-project-mark-files '("Makefile.PL" "Build.PL")
  "*The files tell the current directory should be project root."
  :type '(repeat string)
  :group 'pde-project)

(defcustom pde-file-list-regexp "^[^._#]"
  "Filenames matching this regexp will not be read when `pde-project-find-file'."
  :type 'regexp
  :group 'pde-project)

(defcustom pde-file-list-predicate-function nil
  "Predicate function to filter file to be read when `pde-project-find-file'."
  :type 'function
  :group 'pde-project)

(defcustom pde-file-list-limit 200
  "Maximum number of files for read from project directory recursively."
  :type 'integer
  :group 'pde-project)

(defvar pde-project-root nil)
(defvar pde-file-list-cache nil
  "")

(defun pde-detect-project-root ()
  (let ((dir (expand-file-name default-directory))
        found)
    (catch 'marked
      (while
          (progn
            ;; find Makefile.PL or Build.PL, set project root to current
            (mapc (lambda (f)
                    (when (file-exists-p (concat (file-name-as-directory dir) f))
                      (setq found dir)
                      (throw 'marked nil)))
                  pde-project-mark-files)
            ;; if dir is root, last and set project root to nil
            (cond ((string= dir (directory-file-name dir))
                   nil)
                  ;; if dir is in @INC, last and set project root to current
                  ((member dir pde-perl-inc)
                   (setq found dir)
                   nil)
                  ;; otherwise goes up
                  (t (setq dir (file-name-directory (directory-file-name dir))))))))
    (or found
        (file-name-as-directory default-directory))))

(defun pde-set-project-root ()
  (unless pde-project-root
    (set (make-local-variable 'pde-project-root)
         (pde-detect-project-root))))

(defun pde-file-package ()
  "Get the package name of current buffer."
  (let ((root (or pde-project-root (pde-detect-project-root)))
        package)
    (when (and buffer-file-name
               (string-match "\\.\\(pm\\|pod\\)$" buffer-file-name))
      (setq package (file-relative-name buffer-file-name root))
      (if (string-match (concat "^" (regexp-opt '("blib" "lib")) "/")
                        package)
          (setq package (substring package (match-end 0))))
      (replace-regexp-in-string
       "/" "::"
       (replace-regexp-in-string "\\.\\(pm\\|pod\\)" "" package)))))

(defun pde-directory-all-files (dir &optional full match predicate limit)
  "Recursive read file name in DIR.
Return a cons cell which car indicate whether all files read
and cdr part is the real file list.

Like `directory-files', if FULL is non-nil, return absolute file
names, if match is non-nil, mention only file names match the
regexp MATCH. If PREDICATE is non-nil and is a function with one
argument, the file name relative to DIR, mention only file when
PREDICATE function return non-nil value. If LIMIT is non-nil,
when the files execeed the number will stop. The function is
search in wide-first manner."
  (let ((default-directory (file-name-as-directory dir)))
    (setq limit (or limit most-positive-fixnum))
    (let ((queue (list ""))
          (i 0)
          (finished t)
          list)
      (while (and queue (or (< i limit) (setq finished nil)))
        (setq dir (pop queue))
        (dolist (file (directory-files dir nil match))
          (unless (or (string= file ".") (string= file ".."))
            (setq file (concat dir file))
            (when (or (null predicate) (funcall predicate file))
              (incf i)
              (when (file-directory-p file)
                (setq file (file-name-as-directory file))
                (push file queue))
              (push file list)))))
      (cons finished
            (nreverse (if full (mapcar 'expand-file-name list) list))))))

;;;###autoload 
(defun pde-project-find-file (&optional rebuild)
  "Find file in the project.
This command is will read all file in current project recursively.
With prefix argument, to rebuild the cache."
  (interactive "P")
  (let* ((dir (pde-detect-project-root))
         (pair (assoc dir pde-file-list-cache))
         (file-list (cdr pair)))
    (when (or rebuild (null file-list))
      (setq file-list (pde-directory-all-files
                       dir nil
                       pde-file-list-regexp
                       pde-file-list-predicate-function
                       pde-file-list-limit))
      (if pair
          (setcdr pair file-list)
        (push (cons dir file-list) pde-file-list-cache)))
    (let ((file (expand-file-name (ido-completing-read "Find file: " (cdr file-list) nil t) dir)))
      (if (file-directory-p file)
          (let ((default-directory file))
            (ido-find-file))
        (find-file file)))))

(provide 'pde-project)
;;; pde-project.el ends here
