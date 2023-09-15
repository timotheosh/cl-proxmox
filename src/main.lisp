(defpackage cl-proxmox
  (:use :cl)
  (:export :-main))
(in-package :cl-proxmox)

(defparameter *token-id* "jenkins@pve!PowderyBunionIdeallyManmadeTingleRejoin")
(defparameter *token-secret* "81fa367d-9784-4668-ace1-5e9d6ca24ce3")

(defparameter *node* "northstar")
(defparameter *url* "https://northstar.selfdidactic.lan:8006")
(defparameter *token* (format nil "PVEAPIToken=~A=~A" *token-id* *token-secret*))
(defparameter *ca-file* "/usr/local/share/ca-certificates/Selfdidactic_Intranet_562936459577689798328047806690239883926300597113.crt")

(opts:define-opts
  (:name :help
   :description "print this help text"
   :short #\h
   :long "help"))

(defun unknown-option (condition)
  (format t "warning: ~s option is unknown!~%" (opts:option condition))
  (invoke-restart 'opts:skip-option))

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
           (get-ip (first args))))))
