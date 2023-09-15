(defsystem "cl-proxmox"
  :version "0.1.0"
  :author "Tim Hawes <trhawes@gmail.com>"
  :license "MIT"
  :depends-on ("cl-ppcre"
               "unix-opts"
               "drakma"
               "yason"
               "modf")
  :components ((:module "src"
                :components
                ((:file "main")
                 (:module "node"
                  :components
                  ((:file "qemu"))))))
  :description "Consumer of Proxmox API's"
  :build-operation "asdf:program-op"
  :build-pathname "target/getip"
  :entry-point "cl-proxmox:-main"
  :in-order-to ((test-op (test-op "cl-proxmox/tests"))))

(defsystem "cl-proxmox/tests"
  :author "Tim Hawes <trhawes@gmail.com>"
  :license "MIT"
  :depends-on ("cl-proxmox"
               "fiveam")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-proxmox"
  :perform (test-op (op c) (symbol-call :fiveam :run! (find-symbol* :all-tests :cl-proxmox/tests))))
