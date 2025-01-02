; go run github.com/hymkor/smake@latest

(defglobal EXE     (shell "go env GOEXE"))
(defglobal NAME    (notdir (getwd)))
(defglobal TARGET  (string-append NAME EXE))
(defglobal SOURCE  (wildcard "*.go"))
(defglobal NUL     (if windows "NUL" "/dev/null"))
(defglobal VERSION
  (catch
    'notag
    (with-handler
      (lambda (c) (throw 'notag "v0.0.0"))
      (shell (string-append "git describe --tags 2>" NUL)))))

(case $1
  (("get")
   (sh "go get -u"
       "go mod tidy"))

  (("touch")
   (dolist (fname SOURCE)
     (touch fname)))

  (("clean")
   (dolist (fname (wildcard "*~"))
     (rm fname))
   (if (probe-file TARGET)
     (mv TARGET (string-append "." TARGET "~"))))

  (("install")
   (dolist (path (string-split #\newline (q "where" (notdir $0))))
     (if (not (equal path $0))
       (cp $0 path))))

  (("test")
   (sh "go test"))

  (("dist")
   (dolist (goos '("linux" "windows"))
     (dolist (goarch '("386" "amd64"))
       (env (("GOOS" goos) ("GOARCH" goarch))
         (let* ((exe (shell "go env GOEXE"))
                (target (string-append NAME exe)))
           (rm target)
           (sh "go build")
           (let ((zip-name (string-append NAME "-" VERSION "-" goos "-" goarch ".zip")))
             (if (probe-file zip-name)
               (rm zip-name))
             (spawnlp "zip" zip-name target)))))))

  (("release")
   (let ((b (create-string-output-stream)))
     (format b "gh release create -d --notes \"\" -t")
     (format b " \"~A\"" VERSION)
     (format b " \"~A\"" VERSION)
     (dolist (zip (wildcard (string-append NAME "-" VERSION "-*.zip")))
       (format b " \"~A\"" zip))
     (sh (get-output-stream-string b))))

  (("clean-zip")
   (dolist (fname (wildcard "*.zip"))
     (rm fname))
   (if (probe-file TARGET)
     (rm TARGET)))

  (("manifest")
   (sh (string-append "make-scoop-manifest *-windows-*.zip > " NAME ".json")))

  (("README")
   (sh "example-into-readme"))

  (t
    (let ((ufiles (updatep TARGET "Makefile.lsp" "go.mod" "go.sum" SOURCE)))
      (if ufiles
        (progn
          (format (error-output) "Found update files: ~S~%" ufiles)
          (sh "go fmt ./...")
          (spawnlp "go" "build" "-ldflags"
                   (string-append "-s -w -X main.version=" VERSION)))
        (progn
          (format (error-output) "No files updated~%"))
        ); if
      ); let
    ); t
  ); case

; vim:set lispwords+=env,while:
