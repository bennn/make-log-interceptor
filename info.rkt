#lang info
(define collection "make-log-interceptor")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define pkg-desc "Collects logger messages, filtered by topic and level")
(define version "0.1")
(define pkg-authors '(ben))
(define scribblings '(("scribblings/make-log-interceptor.scrbl" () (tool-library))))
