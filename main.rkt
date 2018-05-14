#lang racket/base

;; make-log-interceptor : execute a thunk and collect logged messages

(require racket/contract racket/logging)

(provide
  log-interceptor/c
  (contract-out
    [make-log-interceptor
      (-> logger? log-interceptor/c)]))

;; =============================================================================

(define log-interceptor/c
  (parametric->/c [A]
    (->* [(-> A)]
         [#:level (or/c log-level/c #f)
          #:topic (or/c symbol? #f)]
         (values A
                 (hash/c log-level/c any/c #:immutable #true #:flat? #true)))))

(define (make-log-interceptor logger)
  (lambda (thunk #:level [pre-level #f] #:topic [pre-topic #false])
    (define topic (or pre-topic (logger-name logger)))
    (define level (or pre-level 'info))
    (define inbox
      (make-hasheq '((debug . ()) (info . ()) (warning . ()) (error . ()) (fatal . ()))))
    (define r
      (with-intercepted-logging
        (λ (l)
          (define lvl (vector-ref l 0))
          (define msg (vector-ref l 1))
          (define tpc (vector-ref l 3))
          (when (eq? topic tpc)
            (hash-update! inbox lvl (λ (msg*) (cons msg msg*)) '())))
        thunk
        #:logger logger
        level))
    (define outbox
      (for/hasheq ([(k v) (in-hash inbox)])
        (values k (reverse v))))
    (values r outbox)))

