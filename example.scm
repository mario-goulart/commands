(import (chicken format)
        (chicken process-context)
        (chicken string))
(import commands)


;;;
;;; Definition of commands
;;;

(define-command 'concat
  #<#EOF
concat arg1 ...
  Concatenate all given arguments.
EOF
  (lambda (args)
    (print (string-intersperse args ""))))

(define-command 'reverse
  #<#EOF
reverse arg1 ...
  Reverse all given arguments.
EOF
  (lambda (args)
    (print (string-intersperse (reverse args)))))


;;;
;;; Code of the main dispatcher program
;;;

;;; Command line parsing and command dispatching
(let ((args (command-line-arguments)))
  (when (null? args)
    (show-main-help 1))

  (when (member (car args) (help-options))
    (show-main-help 0))

  (let ((cmd-name (string->symbol (car args))))
    (or (and-let* ((command (alist-ref cmd-name (commands))))
          ((command-proc command) (cdr args)))
        (begin
          (fprintf (current-error-port) "Invalid command: ~a\n" cmd-name)
          (exit 1)))))
