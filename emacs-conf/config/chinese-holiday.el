;; chinese-holiday.el

(setq local-holidays 
      '(
	(holiday-chinese 1 15 "元宵节 (正月十五)") 
	(holiday-chinese 4 18 "妹妹生日")
	(holiday-chinese 5 5 "端午节 (五月初五)") 
	(holiday-chinese 8 14 "白百合生日")
	(holiday-chinese 8 15 "中秋节 (八月十五)")
	(holiday-chinese 9 9 "重阳节 (九月九)") 
	(holiday-chinese 11 1 "妈妈生日")
	)) 

(autoload 'chinese-year "cal-china" "Chinese year data" t) 

(defun holiday-chinese (cmonth cday string) 
  "Chinese calendar holiday, month and day in Chinese calendar (CMONTH, CDAY). 

If corresponding MONTH and DAY in gregorian calendar is visible, 
the value returned is the list \(((MONTH DAY year) STRING)). 
Returns nil if it is invisible in the current calendar window." 
  (let* ((m displayed-month) 
	 (y displayed-year) 
	 (gdate (calendar-gregorian-from-absolute 
		 (+ (cadr (assoc cmonth (chinese-year y))) (1- cday))))) 
    (increment-calendar-month m y (- 11 (car gdate))) 
    (if (> m 9) (list (list gdate string))))) 
