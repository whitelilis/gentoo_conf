;;; gnus.el ---
;; Copyright 2007 LiuZhe
;; Author: whitelilis@gmail.com

(setq mail-sources '(
                     (file)
                     ))
(setq gnus-select-method '(nnml ""))

;; for news
;; (setq gnus-secondary-select-methods '((nntp "news.cn99.com")))
;; (setq gnus-default-subscribed-newsgroups
;;   '("gnu.emacs.help"
;;     "cn.comp.os.linux"))

;; the following for e-mails

(add-to-list 'gnus-secondary-select-methods '(nnimap "gmail"
                                                     (nnimap-address "imap.gmail.com")
                                                     (nnimap-server-port 993)
                                                     (nnimap-stream ssl)))

;; (setq gnus-default-charset 'chinese-iso-8bit
;;    gnus-group-name-charset-group-alist '((".*" . chinese-iso-8bit))
;;    gnus-summary-show-article-charset-alist
;;        '((1 . chinese-iso-8bit)
;;          (2 . gbk)
;;          (3 . big5)
;;          (4 . utf-8))
;;    gnus-newsgroup-ignored-charsets
;;        '(unknown-8bit x-unknown iso-8859-1))

(eval-after-load "mm-decode"
  '(progn
     (add-to-list 'mm-discouraged-alternatives "text/html")
     (add-to-list 'mm-discouraged-alternatives "text/richtext")))



(setq nnmail-split-methods
       '(("mail.self" "^From:.*whitelilis.*")
         ("mail.test" "whatever")
         ("mail.misc" "")
         ))

(setq gnus-message-archive-group
      '((if (message-news-p)
            "nnml:mail.sent.news"
          "nnml:mail.sent.mail")))

(setq gnus-use-cache 'passive)          ; to save some message
;; (setq gnus-check-new-newsgroups 'ask-server) ;to fast
(setq gnus-save-newsrc-file nil)             ;to fast

(defalias 'mail-header-encode-parameter 'rfc2047-encode-parameter)

;(add-to-list 'rfc2047-charset-encoding-alist '(utf8 . B))
;(add-to-list 'rfc2047-charset-encoding-alist '(gbk . B))
;(add-to-list 'rfc2047-charset-encoding-alist '(gb18030 . B))

(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

;;; .gnus.el ends here
