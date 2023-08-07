(in-package :cl-proxmox)

(setf drakma:*header-stream* *standard-output*)
(defun get/get-ip (vm-id)
  (let* ((response (https-get (format nil "~A/api2/json/nodes/~A/qemu/~A/agent/network-get-interfaces"
                                      *url* *node* vm-id)))
         (data (remove-if (lambda (entry) (string-equal (getf entry :name) "lo0")) response)))
    (mapcar (lambda (entry) (list :hardware-address (getf entry :hardware-address)
                                  :ip-addresses (mapcar (lambda (x) (getf x :ip-address)) (getf entry :ip-addresses)))) data)))
