(module commands

(
 ;; command record
 make-command
 command-name
 command-help
 command-proc
 command?

 define-command
 undefine-command
 commands
 commands-ref

 ;;
 help-options
 handle-help-options
 show-command-help
 show-main-help
)

(import scheme)
(import (chicken base)
        (chicken format)
        (chicken pathname)
        (chicken process-context)
        (chicken sort)
        (chicken string))

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

(define (undefine-command name)
  (set! *commands*
        (reverse
         (let loop ((commands *commands*))
           (if (null? commands)
               '()
               (if (eq? (caar commands) name)
                   (loop (cdr commands))
                   (cons (car commands) (loop (cdr commands)))))))))

(define (show-command-help command #!optional exit-code)
  (let ((port (if (and exit-code (not (zero? exit-code)))
                  (current-error-port)
                  (current-output-port))))
    (display (command-help (commands-ref command)) port)
    (newline port)
    (when exit-code
      (exit exit-code))))

(define (sort-commands-alphabetically commands)
  (sort commands
        (lambda (c1 c2)
          (string<=? (symbol->string (command-name c1))
                     (symbol->string (command-name c2))))))

(define (show-main-help exit-code
                        #!key (message "")
                              (sort-commands sort-commands-alphabetically))
  ;; Show the help message of the main program and all available
  ;; commands.
  (let ((this (pathname-strip-directory (program-name)))
        (help-opts (format "[~a]" (string-intersperse (help-options) "|")))
        (port (if (and exit-code (not (zero? exit-code)))
                  (current-error-port)
                  (current-output-port))))
    (display #<#EOF
Usage: #this #help-opts <command> [<options>]
#message
<commands>:


EOF
)
    (let loop ((commands (sort-commands (map cdr (commands)))))
      (unless (null? commands)
        (display (command-help (car commands)) port)
        (newline)
        (unless (null? (cdr commands))
          (newline))
        (loop (cdr commands))))
    (when exit-code
      (exit exit-code))))


) ;; end module
