(autoload 'dictionary-search "dictionary"
  "Ask for a word and search it in all dictionaries" t)
(autoload 'dictionary-match-words "dictionary"
  "Ask for a word and search all matching words in the dictionaries" t)
(autoload 'dictionary-lookup-definition "dictionary"
  "Unconditionally lookup the word at point." t)
(autoload 'dictionary "dictionary"
  "Create a new dictionary buffer" t)

(global-set-key [(control c)(d)] 'dictionary-lookup-definition)
;(global-set-key [(control c)(s)] 'dictionary-search) ; confilict with cscope
(global-set-key [(control c)(m)] 'dictionary-match-words)

;; choose a dictionary server
(setq dictionary-server "lfs_625")

;; for dictionary tooltip mode
;; choose the dictionary: "wn" for WordNet
;; "web1913" for Webster's Revised Unabridged Dictionary(1913)
;; so on

;;(setq dictionary-tooltip-dictionary "web1913")
;(dictionary-tooltip-mode t)
(setq dictionary-coding-systems-for-dictionaries
'((”chinese” . utf8)
))
