#lang scribble/manual
@require[scribble/example
         (for-label racket/base racket/contract racket/logging make-log-interceptor)]

@title{Intercepted Logging}

@defmodule[make-log-interceptor]{}

@defthing[#:kind "contract" log-interceptor/c 
          (parametric->/c [A]
            (->* [(-> A)]
                 [#:level (or/c log-level/c #f)
                  #:topic (or/c symbol? #false)]
                 (values A
                         (hash/c log-level/c any/c #:immutable #true #:flat? #true))))]{
  A @deftech{log interceptor} for the logger @racket[_L] is a procedure that executes a thunk and returns
   two values:
  @itemlist[#:style 'ordered
  @item{
    the result of the thunk
  }
  @item{
    a @tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{hash} of all
    events logged to @racket[_L] during the thunk, organized by log level.
  }
  ]

  The optional arguments help filter the log events.
  If @racket[#:level] is given, then the returned hash only contains events
   for the given level and higher levels.
  If @racket[#:topic] is given, then the returned hash only contains events
   with the given topic.
  The default level is @racket['info] and the default topic is the value of
   @racket[(logger-name _L)].
}

@margin-note{See also: @racket[with-intercepted-logging]}
@defproc[(make-log-interceptor [logger logger?]) log-interceptor/c]{
  Makes a @tech{log interceptor} for the given logger.

  @examples[#:eval (make-base-eval '(require make-log-interceptor))
    (define ricardo (gensym 'ricardo))
    (define-logger ricardo)
    (define rick-interceptor (make-log-interceptor ricardo-logger))

    (define (f x)
      (when (eq? x ricardo)
        (log-ricardo-info "f spotted a ricardo"))
      (void))

    (define-values [f-result f-logs]
      (rick-interceptor
        (lambda ()
          (f ricardo)
          (f 'fish)
          (f ricardo))))

    f-logs
  ]
}


