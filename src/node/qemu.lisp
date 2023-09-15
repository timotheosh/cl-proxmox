(in-package :cl-proxmox)

(defun get-ip-query (vm-id)
  (let ((stream (drakma:http-request (format nil "~A/api2/json/nodes/~A/qemu/~A/agent/network-get-interfaces"
                                             *url* *node* vm-id)
                                     :ca-file *ca-file*
                                     :additional-headers (list (cons "Authorization" *token*))
                                     :want-stream t)))
    (setf (flexi-streams:flexi-stream-external-format stream) :utf-8)
    (setf yason:*parse-object-key-fn* (lambda (key) (intern (string-upcase key) "KEYWORD")))
    (yason:parse stream :object-as :plist)))


(defun get-ip-full (vm-id)
  (let ((result (get-ip-query vm-id)))
    (car (remove-if (lambda (entry)
                      (string-equal (subseq (getf entry :name) 0 2) "lo")) (first (cdr (cadr result)))))))

(defun get-ip (vm-id)
  (format t "~{~A~%~}" (mapcar (lambda(entry) (getf entry :ip-address)) (getf (get-ip-full vm-id) :ip-addresses))))
