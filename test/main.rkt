#lang racket/base
(module+ test
  (require
    rackunit
    make-log-interceptor
    (only-in racket/port open-output-nowhere))

  (define-logger jj) ;; 'jj' because its short and easy to type
  (define secret-key (gensym))

  (define (jj-thunk)
    (parameterize ([current-error-port (open-output-nowhere)])
      (log-jj-debug "debug hello")
      (log-jj-debug "debug world")
      (log-jj-info "info hello")
      (log-jj-info "info world")
      ;; 2018-05-13 : assume it works for higher levels. I'm not sure how to test
      ;;  without getting prints to stderr
      #;(log-jj-warning "warning hello")
      #;(log-jj-warning "warning world")
      #;(log-jj-error "error hello")
      #;(log-jj-error "error world")
      #;(log-jj-fatal "fatal hello")
      #;(log-jj-fatal "fatal world"))
    secret-key)

  (define (normalize-outbox h)
    (sort (hash->list h) symbol<? #:key car))

  (test-case "standard-interceptor"
    (define interceptor (make-log-interceptor jj-logger))

    (define-values [default-r default-msgs] (interceptor jj-thunk))
    (define-values [info-r info-msgs] (interceptor jj-thunk #:level 'info))
    (define-values [debug-r debug-msgs] (interceptor jj-thunk #:level 'debug))
    (define-values [fatal-r fatal-msgs] (interceptor jj-thunk #:level 'fatal))

    (check-true
      (for/and ((r (in-list (list default-r info-r debug-r fatal-r))))
        (eq? secret-key r))
      "interceptor returns expected value")

    (check-equal?
      default-msgs
      info-msgs
      "default level is 'info'")

    (check-equal?
      (hash-ref info-msgs 'debug)
      '()
      "info level ignores 'debug messages")

    (check-true
      (for/and ((lower-lvl (in-list '(debug info warning error))))
        (eq? '() (hash-ref fatal-msgs lower-lvl)))
      "fatal level ignores others")

    (check-equal?
      (normalize-outbox debug-msgs)
      '((debug . ("jj: debug hello" "jj: debug world"))
        (error . ())
        (fatal . ())
        (info . ("jj: info hello" "jj: info world"))
        (warning . ()))))

  (test-case "off-topic-interceptor"
    (define interceptor (make-log-interceptor jj-logger))

    (define-values [debug-r debug-msgs] (interceptor jj-thunk #:level 'debug #:topic 'barliman))

    (check-equal? debug-r secret-key)

    (check-equal?
      (normalize-outbox debug-msgs)
      '((debug . ())
        (error . ())
        (fatal . ())
        (info . ())
        (warning . ()))))
)
