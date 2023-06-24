(module commands

(
 ;; command record
 make-command
 command-name
 command-help
 command-proc
 command?

 define-command
 commands
 commands-ref

 ;;
 help-options
 handle-help-options
 show-command-help
)

(import scheme)
(import (chicken base))

(define *commands* '())

(define (commands)
  *commands*)

(define-record command name help proc)

(define (commands-ref command-name)
  (alist-ref command-name *commands*))

(define help-options
  (make-parameter '("-h" "-help" "--help")))

(define (handle-help-options cmd args)
  (let loop ((args args))
    (unless (null? args)
      (when (member (car args) (help-options))
        (show-command-help cmd 0)))))

(define (define-command name help proc #!key (handle-help? #t))
  (let ((proc (if handle-help?
                  (lambda (args)
                    (handle-help-options name args)
                    (proc args))
                  proc)))
    (set! *commands*
          (cons (cons name (make-command name help proc))
                *commands*))))

(define (show-command-help command #!optional exit-code)
  (let ((port (if (and exit-code (not (zero? exit-code)))
                  (current-error-port)
                  (current-output-port))))
    (display (command-help (commands-ref command)) port)
    (newline port)
    (when exit-code
      (exit exit-code))))

) ;; end module
