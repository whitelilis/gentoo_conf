
;;; The following lines added by ql:add-to-init-file:
#-quicklisp
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))
(setf *print-pretty* t)


;(proclaim '(optimize (debug 3)))


(setf ccl:*default-file-character-encoding* :utf-8) ; for ccl to load utf-8 file
(setf ccl:*default-external-format*
      (ccl:make-external-format :character-encoding :utf-8
                                :line-termination :unix)
      ccl:*default-file-character-encoding* :utf-8
      ccl:*default-socket-character-encoding* :utf-8
      ccl:*terminal-character-encoding-name* :utf-8)

; for remote slime
;(load "/home/liuzhe/quicklisp/dists/quicklisp/software/slime-20110730-cvs/swank-loader.lisp")
;(funcall (read-from-string "swank-loader:init"))
;(swank:create-server :port 4005 :style :spawn :dont-close t :coding-system "utf-8-unix")

