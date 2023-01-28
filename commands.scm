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
 command-usage
)

(import scheme)
(import (chicken base))

(define *commands* '())

(define (commands)
  *commands*)

(define-record command name help proc)

(define (commands-ref command-name)
  (alist-ref command-name *commands*))

(define (define-command name help proc)
  (set! *commands*
    (cons (cons name (make-command name help proc))
          *commands*)))

(define (command-usage command #!optional exit-code)
  (let ((port (if (and exit-code (not (zero? exit-code)))
                  (current-error-port)
                  (current-output-port))))
    (display (command-help (commands-ref command)) port)
    (newline port)
    (when exit-code
      (exit exit-code))))

) ;; end module
