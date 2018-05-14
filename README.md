make-log-interceptor
===
[![Build Status](https://travis-ci.org/bennn/make-log-interceptor.svg)](https://travis-ci.org/bennn/make-log-interceptor)
[![Scribble](https://img.shields.io/badge/Docs-Scribble-blue.svg)](http://docs.racket-lang.org/make-log-interceptor/index.html)

For collecting log events that occur during a thunk.

The `make-log-interceptor` function expects a logger and returns a
  _log interceptor_ for the given logger.
The _log interceptor_ accepts a thunk, runs the thunk, returns the thunk's
 result, and (most important!) returns a hash table of all log events for
 the given logger organized by log level.


Requires
---

Racket 6.7 or newer


Example
---

```
> (define ricardo (gensym 'ricardo))
> (define-logger ricardo)
> (define rick-interceptor (make-log-interceptor ricardo-logger))
> (define (f x)
    (when (eq? x ricardo)
      (log-ricardo-info "f spotted a ricardo"))
    (void))
> (define-values [f-result f-logs]
    (rick-interceptor
      (lambda ()
        (f ricardo)
        (f 'fish)
        (f ricardo))))
> f-logs
'#hasheq((debug . ())
         (error . ())
         (fatal . ())
         (info
          .
          ("ricardo: f spotted a ricardo" "ricardo: f spotted a ricardo"))
         (warning . ()))
```
