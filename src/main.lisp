(defpackage cl-proxmox
  (:use :cl :serapeum :alexandria)
  (:export :-main))
(in-package :cl-proxmox)

(defparameter *token-id* nil)
(defparameter *token-secret* nil)

(defparameter *node* nil)
(defparameter *url* nil)
(defparameter *ca-file* nil)

(defparameter *config-path* (concatenate 'string (uiop:getenv "HOME") "/.config/cl-proxmox/config.toml"))
(setf yason:*parse-object-key-fn* (lambda (key) (intern (string-upcase key) "KEYWORD")))
(setf yason:*symbol-key-encoder* #'string-downcase)
(setf yason:*parse-json-booleans-as-symbols* t)


(opts:define-opts
  (:name :help
   :description "print this help text"
   :short #\h
   :long "help"))

(defun unknown-option (condition)
  (format t "warning: ~s option is unknown!~%" (opts:option condition))
  (invoke-restart 'opts:skip-option))

(defun read-config ()
  (if (uiop:file-exists-p *config-path*)
      (let* ((data (pp-toml:parse-toml (uiop:read-file-string *config-path*)))
             (secrets (gethash "secrets" data))
             (endpoint (gethash "endpoint" data)))
        (setf *token-id* (gethash "token_id" secrets))
        (setf *token-secret* (gethash "token_secret" secrets))
        (setf *url* (gethash "url" endpoint))
        (setf *node* (gethash "node" endpoint))
        (setf *ca-file* (gethash "rootca" endpoint))
        t)
      (format t "No config in config path ~A~%" *config-path*)))

(defun get-header ()
  (cons "Authorization" (format nil "PVEAPIToken=~A=~A" *token-id* *token-secret*)))

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
           (when (read-config)
             (get-ip 175))))))
