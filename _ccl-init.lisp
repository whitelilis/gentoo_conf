
;;; The following lines added by ql:add-to-init-file:
#-quicklisp
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))
(setf ccl:*default-file-character-encoding* :utf-8) ; for ccl to load utf-8 file
(setf *print-pretty* t)

