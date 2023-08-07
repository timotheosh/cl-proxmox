(defpackage cl-proxmox
  (:use :cl :serapeum :alexandria)
  (:export :-main))
(in-package :cl-proxmox)

(setf yason:*parse-object-key-fn* (lambda (key) (intern (string-upcase key) "KEYWORD")))
(setf yason:*parse-json-booleans-as-symbols* t)


(opts:define-opts
  (:name :help
   :description "print this help text"
   :short #\h
   :long "help"))

(defun unknown-option (condition)
  (format t "warning: ~s option is unknown!~%" (opts:option condition))
  (invoke-restart 'opts:skip-option))

(defun get-header ()
  (cons "Authorization" *token*))

(defun https-get (url)
  (let ((response-stream (drakma:http-request url
                                              :ca-file *ca-file*
                                              :additional-headers (list (get-header))
                                              :want-stream t)))
    (setf (flexi-streams:flexi-stream-external-format response-stream) :utf-8)
    (getf (getf (yason:parse response-stream :object-as :plist) :data) :result)))

(defun -main (&rest args)
  (declare (ignorable args))
  (multiple-value-bind (options args)
      (handler-case
          (handler-bind ((opts:unknown-option #'unknown-option))
            (opts:get-opts)))
    (cond ((getf options :help) 
           (progn (opts:describe
                   :prefix (format nil "cl-proxmox Consumer of Proxmox API's")
                   :usage-of "cl-proxmox INPUT")
                  (opts:exit 1)))
          ((not (= (length args) 1)) 
           (progn (format t "Can only process one argument!")
                  (opts:describe
                   :prefix (format nil "cl-proxmox Consumer of Proxmox API's")
                   :usage-of "cl-proxmox INPUT")
                  (opts:exit 1)))
          (t 
           (format t "Hello, ~A!~%" (first args))))))
