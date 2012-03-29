;;; bbdb.el --- 
;; Copyright 2007 LiuZhe
;; Author: whitelilis@gmail.com


(require 'bbdb)

(setq bbdb-file "~/emacs-conf/other-files/bbdb")

(bbdb-initialize 'gnus 'message)

(setq bbdb-north-american-phone-numbers-p nil)

(setq bbdb-user-mail-names
      (regexp-opt '("whitelilis@gmail.com"
                    "whitelilis@126.com")))
(setq bbdb-complete-name-allow-cycling t)
(setq bbdb-use-pop-up nil)

(add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)

(autoload 'bbdb/gnus-lines-and-from "bbdb-gnus")
(setq gnus-optional-headers 'bbdb/gnus-lines-and-from)

;;; bbdb.el ends here
