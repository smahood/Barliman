(load "mk/mk-vicare.scm")
(load "mk/mk.scm")
(load "mk/test-check.scm")
(load "interp.scm")

(set! allow-incomplete-search? #t)
(set! enable-conde1? #t)

(define-syntax test-barliman
  (syntax-rules ()
    ((_ name (qvars ...) lvars program test-case test-result expected-defs)
     (time
       (test name
         (run 1 (defs qvars ...)
           (let ((g1 (gensym "g1"))
                 (g2 (gensym "g2"))
                 (g3 (gensym "g3"))
                 (g4 (gensym "g4"))
                 (g5 (gensym "g5"))
                 (g6 (gensym "g6"))
                 (g7 (gensym "g7"))
                 (g8 (gensym "g8"))
                 (g9 (gensym "g9"))
                 (g10 (gensym "g10"))
                 (g11 (gensym "g11")))
             (fresh lvars
               (absento g1 defs)
               (absento g2 defs)
               (absento g3 defs)
               (absento g4 defs)
               (absento g5 defs)
               (absento g6 defs)
               (absento g7 defs)
               (absento g8 defs)
               (absento g9 defs)
               (absento g10 defs)
               (absento g11 defs)
               (== program defs)
               (evalo (cons 'begin (append program (list test-case)))
                      test-result))))
         expected-defs)))))

(test-barliman 'quasiquote-1 () ()
  '()
  '(list `(1 2) `((cons 3 4) ,(cons 5 6)))
  `((1 2) ((cons 3 4) (5 . 6)))
  `((())))

(test-barliman 'let*-1 () ()
  '()
  '(let ((x 4))
     (list (let ((x 5) (y (list x x))) y)
           (let* ((x 5) (y (list x x))) y)))
  `((4 4) (5 5))
  `((())))

(let ((program '((define fsm-ho
                   (lambda (str)
                     (letrec ([S0 (lambda (str)
                                    (cond
                                      [(null? str) 'accept]
                                      [else
                                        (let ((d (cdr str)))
                                          (match (car str)
                                            [0 (S0 d)]
                                            [1 (S1 d)])) ]))]
                              [S1 (lambda (str)
                                    (cond
                                      [(null? str) 'reject]
                                      [else
                                        (let ((d (cdr str)))
                                          (match (car str)
                                            [0 (S2 d)]
                                            [1 (S0 d)]))]))]
                              [S2 (lambda (str)
                                    (cond
                                      [(null? str) 'reject]
                                      [else
                                        (let ((d (cdr str)))
                                          (match (car str)
                                            [0 (S1 d)]
                                            [1 (S2 d)]))]))])
                       (S0 str)))))))
  (test-barliman 'fsm-ho-1 () ()
    program
    '(list (fsm-ho '(0 1 1)) (fsm-ho '(0 1 1 1)))
    '(accept reject)
    `((,program))))

(test-barliman
  'rember-1
  () ()
  '((define rember
      (lambda (x ls)
        (cond
          [(null? ls) '()]
          [(equal? x (car ls)) (cdr ls)]
          [else (cons (car ls) (rember x (cdr ls)))]))))
  '(list (rember 'mint '(lamb chops and mint flavored mint jelly))
         (rember 'cup '(coffee cup tea cup and hick cup)))
  '((lamb chops and flavored mint jelly)
    (coffee tea cup and hick cup))
  '((((define rember
        (lambda (x ls)
          (cond
            ((null? ls) '())
            ((equal? x (car ls)) (cdr ls))
            (else (cons (car ls) (rember x (cdr ls)))))))))))

(time
  (test 'rember-2
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7")))
        (fresh (A B C D)
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (== `(define rember
                 (lambda (x ls)
                   (cond
                     [(null? ls) '()]
                     [(equal? ,A (car ls)) ,C]
                     [else ,D])))
              defn)
          (evalo
            `(begin
               ,defn
               (list (rember ',g1 '())
                     (rember ',g1 '(,g1 . ,g2))
                     (rember ',g1 '(,g2 ,g1 . ,g3))
                     (rember ',g1 '(,g2 ,g3 ,g1 . ,g4))))
            `(() ,g2 (,g2 . ,g3) (,g2 ,g3 . ,g4))))))
    '(((define rember
         (lambda (x ls)
           (cond
             ((null? ls) '())
             ((equal? x (car ls)) (cdr ls))
             (else (cons (car ls) (rember x (cdr ls)))))))))))

(time
  (test 'even-odd-1
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7")))
        (fresh ()
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (evalo
            `(begin
               (define even?
                 (lambda (n)
                   (if (null? n)
                     #t
                     (odd? (cdr n)))))
               (define odd?
                 (lambda (n)
                   (if (null? n)
                     #f
                     (even? (cdr n)))))
               (list
                 (even? '())
                 (odd? '())
                 (even? '(s))
                 (odd? '(s))
                 (even? '(s s))
                 (odd? '(s s))))
            (list #t #f #f #t #t #f)))))
      '((_.0))))

(time
  (test 'append-foldr-1*
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7")))
        (fresh (q)
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (== `(define append
                 (lambda (xs ys) ,q))
              defn)
          (evalo `(begin
                    (define foldr
                      (lambda (f acc xs)
                        (if (null? xs)
                          acc
                          (f (car xs) (foldr f acc (cdr xs))))))
                    ,defn
                    (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4) '(,g5 ,g6))))
                 (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6))))))
    '(((define append (lambda (xs ys) (foldr cons ys xs)))))))

(time
  (test 'append-foldr-1
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7")))
        (fresh (q)
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (== `(define append
                 (lambda (xs ys) ,q))
              defn)
          (evalo `(begin
                    (define foldr
                      (lambda (f acc xs)
                        (if (null? xs)
                          acc
                          (f (car xs) (foldr f acc (cdr xs))))))
                    (begin
                      ,defn
                      (list
                        (append '() '())
                        (append '(,g1) '(,g2))
                        (append '(,g3 ,g4) '(,g5 ,g6)))))
                 (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6))))))
    '(((define append (lambda (xs ys) (foldr cons ys xs)))))))

;(time
  ;(test 'foldr-1
    ;(run 1 (defn)
      ;(let ((g1 (gensym "g1"))
            ;(g2 (gensym "g2"))
            ;(g3 (gensym "g3"))
            ;(g4 (gensym "g4"))
            ;(g5 (gensym "g5"))
            ;(g6 (gensym "g6"))
            ;(g7 (gensym "g7")))
        ;(fresh (q)
          ;(absento g1 defn)
          ;(absento g2 defn)
          ;(absento g3 defn)
          ;(absento g4 defn)
          ;(absento g5 defn)
          ;(absento g6 defn)
          ;(absento g7 defn)
          ;(evalo `(begin
                    ;,defn
                    ;(list
                      ;(foldr ',g2 ',g1 '())
                      ;;(foldr cons ',g3 '(,g4))
                      ;(foldr cons ',g4 '(,g5 ,g6))
                      ;(foldr equal? ',g3 '(,g3))
                      ;))
                 ;(list
                   ;g1
                   ;;`(,g4 . ,g3)
                   ;`(,g5 ,g6 . ,g4)
                   ;#t
                   ;)))))
    ;'((ok))))

(time
  (test 'eval-expr-1
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7"))
            (g8 (gensym "g8"))
            (g9 (gensym "g9"))
            (g10 (gensym "g10"))
            (g11 (gensym "g11")))
        (fresh (A)
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (absento g8 defn)
          (absento g9 defn)
          (absento g10 defn)
          (absento g11 defn)
          (== defn
              `(define eval-expr
                 (lambda (expr env)
                   (match expr
                     [`(quote ,datum) datum]
                     [`(lambda (,(? symbol? x)) ,body)
                       (lambda (z)
                         (eval-expr body (lambda (y)
                                           (if (equal? x y)
                                             z
                                             (env y)))))]
                     [(? symbol? x) ,A]
                     [`(cons ,e1 ,e2) (cons (eval-expr e1 env) (eval-expr e2 env))]
                     [`(,rator ,rand) ((eval-expr rator env) (eval-expr rand env))]))))
          (evalo
            `(begin ,defn
                    (list
                      (eval-expr '(quote ,g1) 'initial-env)
                      (eval-expr '((lambda (x) x) (quote ,g2)) 'initial-env)))
            `(,g1 ,g2)))))
    '(((define eval-expr
         (lambda (expr env)
           (match expr
             [`(quote ,datum) datum]
             [`(lambda (,(? symbol? x)) ,body)
               (lambda (z)
                 (eval-expr body (lambda (y)
                                   (if (equal? x y)
                                     z
                                     (env y)))))]
             [(? symbol? x) (env x)]
             [`(cons ,e1 ,e2) (cons (eval-expr e1 env) (eval-expr e2 env))]
             [`(,rator ,rand) ((eval-expr rator env) (eval-expr rand env))])))))))

(time
  (test 'append-fast-1
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7"))
            (g8 (gensym "g8"))
            (g9 (gensym "g9"))
            (g10 (gensym "g10"))
            (g11 (gensym "g11")))
        (fresh ()
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (absento g8 defn)
          (absento g9 defn)
          (absento g10 defn)
          (absento g11 defn)
          (evalo
            `(begin ,defn
                    (list
                      (equal? (cons ',g7 (append '() ',g8)) (append (cons ',g7 '()) ',g8))
                      (equal? (cons ',g4 (append '(,g5) ',g6)) (append (cons ',g4 '(,g5)) ',g6))
                      (equal? (append '(,g9) '(,g10 . ,g11)) (append '(,g9 ,g10) ',g11))))
            '(#t #t #t)))))
    '(((define append
         (lambda (_.0 _.1)
           (if (null? _.0)
             _.1
             (cons (car _.0) (append (cdr _.0) _.1)))))
       (=/= ((_.0 _.1)) ((_.0 append)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons)) ((_.0 if)) ((_.0 null?)) ((_.1 append)) ((_.1 car)) ((_.1 cdr)) ((_.1 cons)) ((_.1 if)) ((_.1 null?)))
       (sym _.0 _.1)))))

(time
  (test 'remove-foo-1
    (run 1 (q)
      (evalo
        `(begin
           (define remove-foo
             (lambda (ls)
               (cond
                 [(null? ls) '()]
                 [(pair? (car ls)) (cons (remove-foo (car ls)) (remove-foo (cdr ls)))]
                 [(equal? (car ls) 'foo) (remove-foo (cdr ls))]
                 [else (cons (car ls) (remove-foo (cdr ls)))])))
           (list (remove-foo '())
                 (remove-foo '(a))
                 (remove-foo '(foo))
                 (remove-foo '(b foo c))
                 (remove-foo '(bar foo baz (foo) foo ((quux foo) foo)))
                 (remove-foo '((d foo) foo (e (foo f foo)) foo g foo (h)))))
        '(() (a) () (b c) (bar baz () ((quux))) ((d) (e (f)) g (h)))))
    '((_.0))))

(time
  (test 'remove-foo-2
    (run 1 (q)
      (evalo
        `(begin
           (define remove-foo
             (lambda (ls)
               (cond
                 [(null? ls) '()]
                 [(pair? (car ls)) (cons (remove-foo (car ls)) (remove-foo (cdr ls)))]
                 [(equal? (car ls) 'foo) (remove-foo (cdr ,q))]
                 [else (cons (car ls) (remove-foo (cdr ls)))])))
           (list (remove-foo '())
                 (remove-foo '(a))
                 (remove-foo '(foo))
                 (remove-foo '(b foo c))
                 (remove-foo '(bar foo baz (foo) foo ((quux foo) foo)))
                 (remove-foo '((d foo) foo (e (foo f foo)) foo g foo (h)))))
        '(() (a) () (b c) (bar baz () ((quux))) ((d) (e (f)) g (h)))))
    '((ls))))

(time (test 'list-nth-element-peano
  (run 1 (q r)
    (evalo `(begin
              (define nth
                (lambda (n xs)
                  (if (null? n) ,q ,r)))
              (list
                (nth '() '(foo bar))
                (nth '(s) '(foo bar))
                (nth '() '(1 2 3))
                (nth '(s) '(1 2 3))
                (nth '(s s) '(1 2 3))))
           (list 'foo 'bar 1 2 3)))
  '((((car xs) (nth (cdr n) (cdr xs)))))))

(time
 (test 'map-hard-0-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (== `(define map
                (lambda (f xs)
                  (if (null? xs)
                    xs (cons (f (car xs)) (map f (cdr xs))))))
             defn)
         (evalo `(begin
                   ,defn
                   (list
                     (map ',g1 '())
                     (map car '((,g2 . ,g3)))
                     (map cdr '((,g4 . ,g5) (,g6 . ,g7)))))
                (list '() `(,g2) `(,g5 ,g7))))))
   '(((define map
        (lambda (f xs)
          (if (null? xs)
            xs (cons (f (car xs)) (map f (cdr xs))))))))))

(time
 (test 'map-hard-1-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh (a b c)
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (== `(define map
                (lambda (f xs)
                  (if (null? xs)
                    ,a (cons ,b (map f ,c)))))
           defn)
         (evalo `(begin
                   ,defn
                   (list
                     (map ',g1 '())
                     (map car '((,g2 . ,g3)))
                     (map cdr '((,g4 . ,g5) (,g6 . ,g7)))))
                (list '() `(,g2) `(,g5 ,g7))))))
   '(((define map
        (lambda (f xs)
          (if (null? xs)
            xs (cons (f (car xs)) (map f (cdr xs))))))))))

(time
 (test 'map-hard-2-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh (a)
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (== `(define map
                (lambda (f xs)
                  (if (null? xs)
                    xs (cons (f (car xs)) (map ,a (cdr xs))))))
             defn)
         (evalo `(begin
                   ,defn
                   (list
                     (map ',g1 '())
                     (map car '((,g2 . ,g3)))
                     (map cdr '((,g4 . ,g5) (,g6 . ,g7)))))
                (list '() `(,g2) `(,g5 ,g7))))))
   '(((define map
        (lambda (f xs)
          (if (null? xs)
            xs (cons (f (car xs)) (map f (cdr xs))))))))))

;(time
 ;(test 'map-hard-3-gensym
   ;(run 1 (defn)
     ;(let ((g1 (gensym "g1"))
           ;(g2 (gensym "g2"))
           ;(g3 (gensym "g3"))
           ;(g4 (gensym "g4"))
           ;(g5 (gensym "g5"))
           ;(g6 (gensym "g6"))
           ;(g7 (gensym "g7")))
       ;(fresh (a)
         ;(absento g1 defn)
         ;(absento g2 defn)
         ;(absento g3 defn)
         ;(absento g4 defn)
         ;(absento g5 defn)
         ;(absento g6 defn)
         ;(absento g7 defn)
         ;(== `(define map
                ;(lambda (f xs) ,a))
             ;defn)
         ;(evalo `(begin
                   ;,defn
                   ;(list
                     ;(map ',g1 '())
                     ;(map car '((,g2 . ,g3)))
                     ;(map cdr '((,g4 . ,g5) (,g6 . ,g7)))))
                ;(list '() `(,g2) `(,g5 ,g7))))))
   ;'(((define map
        ;(lambda (f xs)
          ;(if (null? xs)
            ;xs (cons (f (car xs)) (map f (cdr xs))))))))))

;(time
 ;(test 'map-hard-4-gensym
   ;(run 1 (defn)
     ;(let ((g1 (gensym "g1"))
           ;(g2 (gensym "g2"))
           ;(g3 (gensym "g3"))
           ;(g4 (gensym "g4"))
           ;(g5 (gensym "g5"))
           ;(g6 (gensym "g6"))
           ;(g7 (gensym "g7")))
       ;(fresh ()
         ;(absento g1 defn)
         ;(absento g2 defn)
         ;(absento g3 defn)
         ;(absento g4 defn)
         ;(absento g5 defn)
         ;(absento g6 defn)
         ;(absento g7 defn)
         ;(evalo `(begin
                   ;,defn
                   ;(list
                     ;(map ',g1 '())
                     ;(map car '((,g2 . ,g3)))
                     ;(map cdr '((,g4 . ,g5) (,g6 . ,g7)))))
                ;(list '() `(,g2) `(,g5 ,g7))))))
   ;'(((define map
        ;(lambda (_.0 _.1)
          ;(if (null? _.1)
            ;_.1 (cons (_.0 (car _.1)) (map _.0 (cdr _.1))))))
      ;(sym _.0 _.1)))))

(test 'append-empty
  (run 1 (q)
       (evalo
         `(begin
            (define append
              (lambda (l s)
                (if (null? l)
                  s
                  (cons (car l)
                        (append (cdr l) s)))))
            (append '() '()))
         '()))
  '((_.0)))

(test 'append-all-answers
  (run* (l1 l2)
        (evalo `(begin
                  (define append
                    (lambda (l s)
                      (if (null? l)
                        s
                        (cons (car l)
                              (append (cdr l) s)))))
                  (append ',l1 ',l2))
               '(1 2 3 4 5)))
  '(((() (1 2 3 4 5)))
    (((1) (2 3 4 5)))
    (((1 2) (3 4 5)))
    (((1 2 3) (4 5)))
    (((1 2 3 4) (5)))
    (((1 2 3 4 5) ()))))

;;; flipping rand/body eval order makes this one too hard,
;;; but dynamic ordering via eval-application fixes it!
(test 'append-cons-first-arg
  (run 1 (q)
    (evalo `(begin (define append
                     (lambda (l s)
                       (if (null? l)
                         s
                         (cons ,q
                               (append (cdr l) s)))))
                   (append '(1 2 3) '(4 5)))
           '(1 2 3 4 5)))
  '(((car l))))

(test 'append-cdr-arg
  (run 1 (q)
       (evalo `(begin
                 (define append
                   (lambda (l s)
                     (if (null? l)
                       s
                       (cons (car l)
                             (append (cdr ,q) s)))))
                 (append '(1 2 3) '(4 5)))
              '(1 2 3 4 5)))
  '((l)))

(test 'append-cdr
  (run 1 (q)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons (car l)
                          (append (,q l) s)))))
              (append '(1 2 3) '(4 5)))
           '(1 2 3 4 5)))
  '((cdr)))

(time (test 'append-hard-1
  (run 1 (q r)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons (car l)
                          (append (,q ,r) s)))))
              (append '(1 2 3) '(4 5)))
           '(1 2 3 4 5)))
  '(((cdr l)))))

(time (test 'append-hard-2
  (run 1 (q)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons (car l)
                          (append ,q s)))))
              (append '(1 2 3) '(4 5)))
           '(1 2 3 4 5)))
  '(((cdr l)))))

(time (test 'append-hard-3
  (run 1 (q r)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons (car l)
                          (append ,q ,r)))))
              (list
                (append '(foo) '(bar))
                (append '(1 2 3) '(4 5))))
           (list '(foo bar) '(1 2 3 4 5))))
  '((((cdr l) s)))))

(time (test 'append-hard-4
  (run 1 (q)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons (car l)
                          (append . ,q)))))
              (list
                (append '(foo) '(bar))
                (append '(1 2 3) '(4 5))))
           (list '(foo bar) '(1 2 3 4 5))))
  '((((cdr l) s)))))

(time (test 'append-hard-5
  (run 1 (q r)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons ,q
                          (append . ,r)))))
              (list
                (append '() '())
                (append '(foo) '(bar))
                (append '(1 2 3) '(4 5))))
           (list '() '(foo bar) '(1 2 3 4 5))))
  '((((car l) ((cdr l) s))))))

;; the following are still overfitting
;; probably need to demote quote and some others

(time
 (test 'append-hard-6-gensym-dummy-test
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q a b)

           (== `(append ,a ,b) q)

           (== `(define append
                  (lambda (l s)
                    (if (null? l)
                        s
                        (cons (car l) ,q))))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(printf "append-hard-6-gensym-less-dummy-test takes ~~16s\n")
(time
 (test 'append-hard-6-gensym-less-dummy-test
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q a b c)

           (== `(,a ,b ,c) q)

           (== `(define append
                  (lambda (l s)
                    (if (null? l)
                        s
                        (cons (car l) ,q))))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(printf "append-hard-6-no-gensym returns an over-specific, incorrect answer\n")
(time (test 'append-hard-6-no-gensym
  (run 1 (q)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons (car l) ,q))))
              (list
                (append '() '())
                (append '(foo) '(bar))
                (append '(1 2 3) '(4 5))))
           (list '() '(foo bar) '(1 2 3 4 5))))
  '(((append (cdr l) s)))))

(time
 (test 'append-hard-6-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q)
           (== `(define append
                  (lambda (l s)
                    (if (null? l)
                        s
                        (cons (car l) ,q))))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(time
 (test 'append-hard-7-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q r)
           (== `(define append
                  (lambda (l s)
                    (if (null? l)
                        s
                        (cons ,q ,r))))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(test 'append-hard-7-no-gensym
  (run 1 (q r)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l)
                    s
                    (cons ,q ,r))))
              (list
                (append '() '())
                (append '(foo) '(bar))
                (append '(1 2 3) '(4 5))))
           (list '() '(foo bar) '(1 2 3 4 5))))
  '((((car l) (append (cdr l) s)))))

(time
 (test 'append-hard-8-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q)
           (== `(define append
                  (lambda (l s)
                    (if (null? l)
                        s
                        ,q)))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(time
 (test 'append-hard-9-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q r)
           (== `(define append
                  (lambda (l s)
                    (if (null? l)
                        ,q
                        ,r)))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(time
 (test 'append-hard-10-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q r s)
           (== `(define append
                  (lambda (l s)
                    (if (null? ,q)
                        ,r
                        ,s)))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(time
 (test 'append-hard-11-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q r s t)
           (== `(define append
                  (lambda (l s)
                    (if (,t ,q)
                        ,r
                        ,s)))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(time
  (test 'append-equal-0
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7")))
        (fresh ()
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (evalo `(begin
                    ,defn
                    (list
                      (equal? '() (append '() '()))
                      (equal? (list ',g1 ',g2) (append '(,g1) '(,g2)))
                      (equal? (list ',g3 ',g4 ',g5 ',g6) (append '(,g3 ,g4) '(,g5 ,g6)))))
                  (list #t #t #t)))))
    '(((define append (lambda (_.0 _.1) (if (null? _.0) _.1 (cons (car _.0) (append (cdr _.0) _.1)))))
        (=/= ((_.0 _.1)) ((_.0 append)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons)) ((_.0 if)) ((_.0 null?)) ((_.1 append)) ((_.1 car)) ((_.1 cdr)) ((_.1 cons)) ((_.1 if)) ((_.1 null?)))
        (sym _.0 _.1)))))

(time
  (test 'append-equal-1
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7")))
        (fresh ()
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (evalo `(begin
                    ,defn
                    (list
                      (equal? (append '() '()) '())
                      (equal? (append '(,g1) '(,g2)) (list ',g1 ',g2))
                      (equal? (append '(,g3 ,g4) '(,g5 ,g6)) (list ',g3 ',g4 ',g5 ',g6))))
                  (list #t #t #t)))))
    '(((define append (lambda (_.0 _.1) (if (null? _.0) _.1 (cons (car _.0) (append (cdr _.0) _.1)))))
        (=/= ((_.0 _.1)) ((_.0 append)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons)) ((_.0 if)) ((_.0 null?)) ((_.1 append)) ((_.1 car)) ((_.1 cdr)) ((_.1 cons)) ((_.1 if)) ((_.1 null?)))
        (sym _.0 _.1)))))

(time
  (test 'interp-0
    (run 1 (defn)
      (let ((g1 (gensym "g1"))
            (g2 (gensym "g2"))
            (g3 (gensym "g3"))
            (g4 (gensym "g4"))
            (g5 (gensym "g5"))
            (g6 (gensym "g6"))
            (g7 (gensym "g7")))
        (fresh (a b c d)
          (absento g1 defn)
          (absento g2 defn)
          (absento g3 defn)
          (absento g4 defn)
          (absento g5 defn)
          (absento g6 defn)
          (absento g7 defn)
          (== `(define eval-expr
                 (lambda (expr env)
                   (match expr
                     [`(quote ,datum) datum]
                     [`(lambda (,(? symbol? x)) ,body)
                       (lambda (a)
                         (eval-expr body (lambda (y)
                                           (if (equal? ,a ,b)
                                             ,c
                                             (env ,d)))))]
                     [(? symbol? x) (env x)]
                     [`(cons ,e1 ,e2) (cons (eval-expr e1 env) (eval-expr e2 env))]
                     [`(,rator ,rand) ((eval-expr rator env) (eval-expr rand env))])))
              defn)
          (evalo `(begin
                    ,defn
                    (list
                      (eval-expr '((lambda (y) y) ',g1) 'initial-env)
                      (eval-expr '(((lambda (z) z) (lambda (v) v)) ',g2) 'initial-env)
                      (eval-expr '(((lambda (a) (a a)) (lambda (b) b)) ',g3) 'initial-env)
                      (eval-expr '(((lambda (c) (lambda (d) c)) ',g4) ',g5) 'initial-env)
                      (eval-expr '(((lambda (f) (lambda (v1) (f (f v1)))) (lambda (e) e)) ',g6) 'initial-env)
                      (eval-expr '((lambda (g) ((g g) g)) (lambda (i) (lambda (j) ',g7))) 'initial-env)
                      ))
                 (list
                   g1
                   g2
                   g3
                   g4
                   g6
                   g7
                   )))))
    '(((define eval-expr
         (lambda (expr env)
           (match expr
             [`(quote ,datum) datum]
             [`(lambda (,(? symbol? x)) ,body)
               (lambda (a)
                 (eval-expr body (lambda (y)
                                   (if (equal? y x)
                                     a
                                     (env y)))))]
             [(? symbol? x) (env x)]
             [`(cons ,e1 ,e2) (cons (eval-expr e1 env) (eval-expr e2 env))]
             [`(,rator ,rand) ((eval-expr rator env) (eval-expr rand env))])))))))

;(time
  ;(test 'interp-1
    ;(run 1 (defn)
      ;(let ((g1 (gensym "g1"))
            ;(g2 (gensym "g2"))
            ;(g3 (gensym "g3"))
            ;(g4 (gensym "g4"))
            ;(g5 (gensym "g5"))
            ;(g6 (gensym "g6"))
            ;(g7 (gensym "g7")))
        ;(fresh (a b c d)
          ;(absento g1 defn)
          ;(absento g2 defn)
          ;(absento g3 defn)
          ;(absento g4 defn)
          ;(absento g5 defn)
          ;(absento g6 defn)
          ;(absento g7 defn)
          ;(== `(define eval-expr
                 ;(lambda (expr env)
                   ;(match expr
                     ;[`(quote ,datum) datum]
                     ;[`(lambda (,(? symbol? x)) ,body)
                       ;(lambda (a)
                         ;(eval-expr body (lambda (y)
                                           ;(if (equal? ,a ,b)
                                             ;,c
                                             ;,d))))]
                     ;[(? symbol? x) (env x)]
                     ;[`(cons ,e1 ,e2) (cons (eval-expr e1 env) (eval-expr e2 env))]
                     ;[`(,rator ,rand) ((eval-expr rator env) (eval-expr rand env))])))
              ;defn)
          ;(evalo `(begin
                    ;,defn
                    ;(list
                      ;(eval-expr '((lambda (y) y) ',g1) 'initial-env)
                      ;(eval-expr '(((lambda (z) z) (lambda (v) v)) ',g2) 'initial-env)
                      ;(eval-expr '(((lambda (a) (a a)) (lambda (b) b)) ',g3) 'initial-env)
                      ;(eval-expr '(((lambda (c) (lambda (d) c)) ',g4) ',g5) 'initial-env)
                      ;(eval-expr '(((lambda (f) (lambda (v1) (f (f v1)))) (lambda (e) e)) ',g6) 'initial-env)
                      ;(eval-expr '((lambda (g) ((g g) g)) (lambda (i) (lambda (j) ',g7))) 'initial-env)
                      ;))
                 ;(list
                   ;g1
                   ;g2
                   ;g3
                   ;g4
                   ;g6
                   ;g7
                   ;)))))
    ;'(((define eval-expr
         ;(lambda (expr env)
           ;(match expr
             ;[`(quote ,datum) datum]
             ;[`(lambda (,(? symbol? x)) ,body)
               ;(lambda (a)
                 ;(eval-expr body (lambda (y)
                                   ;(if (equal? y x)
                                     ;a
                                     ;(env y)))))]
             ;[(? symbol? x) (env x)]
             ;[`(cons ,e1 ,e2) (cons (eval-expr e1 env) (eval-expr e2 env))]
             ;[`(,rator ,rand) ((eval-expr rator env) (eval-expr rand env))])))))))

(time
 (test 'append-hard-12-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q r s)
           (== `(define append
                  (lambda (l s)
                    (if ,q
                        ,r
                        ,s)))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(time
 (test 'append-hard-13-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (fresh (q)
           (== `(define append
                  (lambda (l s) ,q))
               defn)
           (evalo `(begin
                     ,defn
                     (list
                      (append '() '())
                      (append '(,g1) '(,g2))
                      (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                  (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7)))))))
   '(((define append (lambda (l s) (if (null? l) s (cons (car l) (append (cdr l) s)))))))))

(time
 (test 'append-hard-14-gensym
   (run 1 (defn)
     (let ((g1 (gensym "g1"))
           (g2 (gensym "g2"))
           (g3 (gensym "g3"))
           (g4 (gensym "g4"))
           (g5 (gensym "g5"))
           (g6 (gensym "g6"))
           (g7 (gensym "g7")))
       (fresh ()
         (absento g1 defn)
         (absento g2 defn)
         (absento g3 defn)
         (absento g4 defn)
         (absento g5 defn)
         (absento g6 defn)
         (absento g7 defn)
         (evalo `(begin
                   ,defn
                   (list
                     (append '() '())
                     (append '(,g1) '(,g2))
                     (append '(,g3 ,g4 ,g5) '(,g6 ,g7))))
                (list '() `(,g1 ,g2) `(,g3 ,g4 ,g5 ,g6 ,g7))))))
   '(((define append (lambda (_.0 _.1) (if (null? _.0) _.1 (cons (car _.0) (append (cdr _.0) _.1)))))
      (=/= ((_.0 _.1)) ((_.0 append)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons)) ((_.0 if)) ((_.0 null?)) ((_.1 append)) ((_.1 car)) ((_.1 cdr)) ((_.1 cons)) ((_.1 if)) ((_.1 null?)))
      (sym _.0 _.1)))))

(time (test 'reverse-1
  (run 1 (q r s)
    (evalo `(begin
              (define append
                (lambda (l s)
                  (if (null? l) s
                    (cons (car l)
                          (append (cdr l) s)))))
              (begin
                (define reverse
                  (lambda (xs)
                    (if (null? xs) '()
                      (,q (reverse ,r) ,s))))
                (list
                  (reverse '())
                  (reverse '(a))
                  (reverse '(foo bar))
                  (reverse '(1 2 3)))))
          (list '() '(a) '(bar foo) '(3 2 1))))
  '(((append (cdr xs) (cons (car xs) '()))))))

(time (test 'reverse-2
  (run 1 (defn)
    (let ((g1 (gensym "g1"))
          (g2 (gensym "g2"))
          (g3 (gensym "g3"))
          (g4 (gensym "g4"))
          (g5 (gensym "g5"))
          (g6 (gensym "g6"))
          (g7 (gensym "g7")))
      (fresh (q r s)
        (absento g1 defn)
        (absento g2 defn)
        (absento g3 defn)
        (absento g4 defn)
        (absento g5 defn)
        (absento g6 defn)
        (absento g7 defn)
        (== `(define reverse
               (lambda (xs)
                 (if (null? xs)
                   '()
                   (,q (reverse ,r) ,s))))
            defn)
        (evalo `(begin
                  (define append
                    (lambda (l s)
                      (if (null? l) s
                        (cons (car l)
                              (append (cdr l) s)))))
                  (begin
                    ,defn
                    (list
                      (reverse '())
                      (reverse '(,g1))
                      (reverse '(,g2 ,g3))
                      (reverse '(,g4 ,g5 ,g6)))))
               (list '() `(,g1) `(,g3 ,g2) `(,g6 ,g5 ,g4))))))
  '(((define reverse
       (lambda (xs)
         (if (null? xs)
           '()
           (append (reverse (cdr xs))
                   (cons (car xs) '())))))))))

;(time (test 'reverse-3
  ;(run 1 (defn)
    ;(let ((g1 (gensym "g1"))
          ;(g2 (gensym "g2"))
          ;(g3 (gensym "g3"))
          ;(g4 (gensym "g4"))
          ;(g5 (gensym "g5"))
          ;(g6 (gensym "g6"))
          ;(g7 (gensym "g7")))
      ;(fresh (q r s)
        ;(absento g1 defn)
        ;(absento g2 defn)
        ;(absento g3 defn)
        ;(absento g4 defn)
        ;(absento g5 defn)
        ;(absento g6 defn)
        ;(absento g7 defn)
        ;(== `(define reverse
               ;(lambda (xs)
                 ;(if (null? xs)
                   ;'()
                   ;(append (,q ,r) ,s))))
            ;defn)
        ;(evalo `(begin
                  ;(define append
                    ;(lambda (l s)
                      ;(if (null? l) s
                        ;(cons (car l)
                              ;(append (cdr l) s)))))
                  ;(begin
                    ;,defn
                    ;(list
                      ;(reverse '())
                      ;(reverse '(,g1))
                      ;(reverse '(,g2 ,g3))
                      ;(reverse '(,g4 ,g5 ,g6)))))
               ;(list '() `(,g1) `(,g3 ,g2) `(,g6 ,g5 ,g4))))))
  ;'(((define reverse
       ;(lambda (xs)
         ;(if (null? xs)
           ;'()
           ;(append (reverse (cdr xs))
                   ;(list (car xs))))))))))

;(time (test 'reverse-4
  ;(run 1 (defn)
    ;(let ((g1 (gensym "g1"))
          ;(g2 (gensym "g2"))
          ;(g3 (gensym "g3"))
          ;(g4 (gensym "g4"))
          ;(g5 (gensym "g5"))
          ;(g6 (gensym "g6"))
          ;(g7 (gensym "g7")))
      ;(fresh (q r)
        ;(absento g1 defn)
        ;(absento g2 defn)
        ;(absento g3 defn)
        ;(absento g4 defn)
        ;(absento g5 defn)
        ;(absento g6 defn)
        ;(absento g7 defn)
        ;(== `(define reverse
               ;(lambda (xs)
                 ;(if (null? xs)
                   ;'()
                   ;(append ,q ,r))))
            ;defn)
        ;(evalo `(begin
                  ;(define append
                    ;(lambda (l s)
                      ;(if (null? l) s
                        ;(cons (car l)
                              ;(append (cdr l) s)))))
                  ;(begin
                    ;,defn
                    ;(list
                      ;(reverse '())
                      ;(reverse '(,g1))
                      ;(reverse '(,g2 ,g3))
                      ;(reverse '(,g4 ,g5 ,g6)))))
               ;(list '() `(,g1) `(,g3 ,g2) `(,g6 ,g5 ,g4))))))
  ;'(((define reverse
       ;(lambda (xs)
         ;(if (null? xs)
           ;'()
           ;(append (reverse (cdr xs))
                   ;(list (car xs))))))))))

;(time (test 'reverse-5
  ;(run 1 (defn)
    ;(let ((g1 (gensym "g1"))
          ;(g2 (gensym "g2"))
          ;(g3 (gensym "g3"))
          ;(g4 (gensym "g4"))
          ;(g5 (gensym "g5"))
          ;(g6 (gensym "g6"))
          ;(g7 (gensym "g7")))
      ;(fresh (q)
        ;(absento g1 defn)
        ;(absento g2 defn)
        ;(absento g3 defn)
        ;(absento g4 defn)
        ;(absento g5 defn)
        ;(absento g6 defn)
        ;(absento g7 defn)
        ;(absento 'match defn)
        ;(== `(define reverse
               ;(lambda (xs)
                 ;(if (null? xs)
                   ;'()
                   ;,q)))
            ;defn)
        ;(evalo `(begin
                  ;(define append
                    ;(lambda (l s)
                      ;(if (null? l) s
                        ;(cons (car l)
                              ;(append (cdr l) s)))))
                  ;(begin
                    ;,defn
                    ;(list
                      ;(reverse '())
                      ;(reverse '(,g1))
                      ;(reverse '(,g2 ,g3))
                      ;(reverse '(,g4 ,g5 ,g6)))
                    ;)
                  ;)
               ;(list '() `(,g1) `(,g3 ,g2) `(,g6 ,g5 ,g4))))))
  ;'(((define reverse
       ;(lambda (xs)
         ;(if (null? xs)
           ;'()
           ;(append (reverse (cdr xs))
                   ;(list (car xs))))))))))

;(time (test 'reverse-6
  ;(run 1 (defn)
    ;(let ((g1 (gensym "g1"))
          ;(g2 (gensym "g2"))
          ;(g3 (gensym "g3"))
          ;(g4 (gensym "g4"))
          ;(g5 (gensym "g5"))
          ;(g6 (gensym "g6"))
          ;(g7 (gensym "g7")))
      ;(fresh (q r s)
        ;(absento g1 defn)
        ;(absento g2 defn)
        ;(absento g3 defn)
        ;(absento g4 defn)
        ;(absento g5 defn)
        ;(absento g6 defn)
        ;(absento g7 defn)
        ;(== `(define reverse
               ;(lambda (xs)
                 ;(if ,q ,r ,s)))
            ;defn)
        ;(evalo `(begin
                  ;(define foldl
                    ;(lambda (f acc xs)
                      ;(if (null? xs)
                        ;acc
                        ;(foldl f (f (car xs) acc) (cdr xs)))))
                  ;(begin
                    ;,defn
                    ;(list
                      ;(reverse '())
                      ;(reverse '(,g1))
                      ;(reverse '(,g2 ,g3))
                      ;(reverse '(,g4 ,g5 ,g6)))))
               ;(list '() `(,g1) `(,g3 ,g2) `(,g6 ,g5 ,g4))))))
  ;'(((define reverse
       ;(lambda (xs)
         ;(if (null? xs)
           ;xs
           ;(foldl cons '() xs))))))))

(time (test 'reverse-7
  (run 1 (defn)
    (let ((g1 (gensym "g1"))
          (g2 (gensym "g2"))
          (g3 (gensym "g3"))
          (g4 (gensym "g4"))
          (g5 (gensym "g5"))
          (g6 (gensym "g6"))
          (g7 (gensym "g7")))
      (fresh (q r s)
        (absento g1 defn)
        (absento g2 defn)
        (absento g3 defn)
        (absento g4 defn)
        (absento g5 defn)
        (absento g6 defn)
        (absento g7 defn)
        (== `(define reverse
               (lambda (xs) ,q))
            defn)
        (evalo `(begin
                  (define foldl
                    (lambda (f acc xs)
                      (if (null? xs)
                        acc
                        (foldl f (f (car xs) acc) (cdr xs)))))
                  (begin
                    ,defn
                    (list
                      (reverse '())
                      (reverse '(,g1))
                      (reverse '(,g2 ,g3))
                      (reverse '(,g4 ,g5 ,g6)))))
               (list '() `(,g1) `(,g3 ,g2) `(,g6 ,g5 ,g4))))))
  '(((define reverse (lambda (xs) (foldl cons '() xs)))))))

;(time (test 'reverse-8
  ;(run 1 (defn)
    ;(let ((g1 (gensym "g1"))
          ;(g2 (gensym "g2"))
          ;(g3 (gensym "g3"))
          ;(g4 (gensym "g4"))
          ;(g5 (gensym "g5"))
          ;(g6 (gensym "g6"))
          ;(g7 (gensym "g7")))
      ;(fresh ()
        ;(absento g1 defn)
        ;(absento g2 defn)
        ;(absento g3 defn)
        ;(absento g4 defn)
        ;(absento g5 defn)
        ;(absento g6 defn)
        ;(absento g7 defn)
        ;(evalo `(begin
                  ;(define foldl
                    ;(lambda (f acc xs)
                      ;(if (null? xs)
                        ;acc
                        ;(foldl f (f (car xs) acc) (cdr xs)))))
                  ;(begin
                    ;,defn
                    ;(list
                      ;(reverse '())
                      ;(reverse '(,g1))
                      ;(reverse '(,g2 ,g3))
                      ;(reverse '(,g4 ,g5 ,g6)))))
               ;(list '() `(,g1) `(,g3 ,g2) `(,g6 ,g5 ,g4))))))
  ;'(((define reverse
       ;(lambda (xs)
         ;(if (null? xs)
           ;xs
           ;(foldl cons '() xs))))))))

(time (test 'rev-tailcall-1
  (run 1 (defn)
    (let ((g1 (gensym "g1"))
          (g2 (gensym "g2"))
          (g3 (gensym "g3"))
          (g4 (gensym "g4"))
          (g5 (gensym "g5"))
          (g6 (gensym "g6"))
          (g7 (gensym "g7")))
      (fresh (q r s)
        (absento g1 defn)
        (absento g2 defn)
        (absento g3 defn)
        (absento g4 defn)
        (absento g5 defn)
        (absento g6 defn)
        (absento g7 defn)
        (evalo `(begin
                  ,defn
                  (list
                    (rev-tailcall '() ',g7)
                    (rev-tailcall '(,g1) ',g7)
                    (rev-tailcall '(,g2 ,g3) ',g7)
                    (rev-tailcall '(,g4 ,g5 ,g6) ',g7)))
               (list g7 `(,g1 . ,g7) `(,g3 ,g2 . ,g7) `(,g6 ,g5 ,g4 . ,g7))))))
  '(((define rev-tailcall
       (lambda (_.0 _.1)
         (if (null? _.0)
           _.1
           (rev-tailcall (cdr _.0) (cons (car _.0) _.1)))))
     (=/= ((_.0 _.1)) ((_.0 car)) ((_.0 cdr)) ((_.0 cons)) ((_.0 if)) ((_.0 null?)) ((_.0 rev-tailcall)) ((_.1 car)) ((_.1 cdr)) ((_.1 cons)) ((_.1 if)) ((_.1 null?)) ((_.1 rev-tailcall)))
     (sym _.0 _.1)))))
