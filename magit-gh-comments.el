(require 'eieio)

(require 'magit)
(require 'gh)
(require 'gh-pulls)
(require 'gh-comments)
(require 'gh-pull-comments)
(require 'gh-issue-comments)
(require 'pcache)
(require 's)


(defun magit-gh-comments-get-api ()
  (gh-comments-api "api" :sync t :num-retries 1 :cache (gh-cache "cache")))

(defun magit-gh-pulls-comments-get-api ()
  (gh-pull-comments-api "api" :sync t :num-retries 1 :cache (gh-cache "cache")))

(defun magit-gh-pulls-issue-comments-get-api ()
  (gh-issue-comments-api "api" :sync t :num-retries 1 :cache (gh-cache "cache")))

(defun magit-gh-pulls-pull-buffer-name (user proj id)
  "Compose name of PR comments buffer with USER, PROJ and pr ID."
  (format "*magit-gh-pulls-%s-%s-#%s" user proj id))

(defun magit-gh-pulls-pull-comments-entries (user proj id)
  "Get the comments of a PR for USER, PROJ and ID.
A PR can have global comments or comments related to PR commits.
This function returns both."
  (let ((repo (magit-gh-pulls-guess-repo)))
    (when repo
      (let* ((issue-api (magit-gh-pulls-issue-comments-get-api))
             (pulls-api (magit-gh-pulls-comments-get-api))
             (comment-api (magit-gh-comments-get-api))
             (commit-comments (oref (gh-comments-list-commit comment-api user proj "d3bf9be") :data))
             (issue-comments (oref (gh-issue-comments-list issue-api user proj id) :data))
             (pull-comments (oref (gh-pull-comments-list pulls-api user proj id) :data)))
        (append issue-comments commit-comments)))))

(defun magit-gh-pulls-format-pull-comment-time (time)
  "Format TIME with 'nice' style for comments."
  (let ((format "%d/%m/%Y %H:%M:%S"))
    (format-time-string format (date-to-time time))))

(defun magit-gh-pulls-pull-buffer (user proj id)
  "Return PR buffer for USER,PROJ and ID if it exists."
  (get-buffer (magit-gh-pulls-pull-buffer-name user proj id)))


;; (defun bff (action)
;;   (lexical-let ((path path) (commit-id commit-id) (position position))
;;     (insert-text-button path
;;                         'follow-link t
;;                         'help-echo "Click button"
;;                         'action #'(lambda (button)
;;                                    (my-open-revision-file path commit-id position)
;;                                    ))))
;;TODO:
;; add link to path
;; add replay to commit, edit, remove
;; https://github.com/sigma/gh.el/blob/master/gh-pull-comments.el
;; https://github.com/areina/magit-gh-pulls/blob/42dc26163eb5791dd8ceb8ce9a8813a2d9a01a3d/magit-gh-pulls.el
;; {
;;   "body": "Nice change",
;;   "in_reply_to": 4
;; }
;; (defvar endless/gh-timer (run-with-idle-timer 30 'repeat
;; #'magit-gh-pulls-reload))


(require 'button)
(defun bff (label action)
  (insert-text-button label 'follow-link t 'action action))

(defun my-open-revision-file (path commit-id position)
  (magit-find-file-other-window commit-id path)
  (interactive)
  (with-no-warnings
    (goto-line position)))

(defun my-pulls-comments-replay (comment-id user proj id)
  (let ((body (read-from-minibuffer "Replay: ")))
    (let ((repo (magit-gh-pulls-guess-repo))
          (comment (make-instance 'gh-pull-comments-comment :body body :in-reply-to comment-id)))
      (when repo
        (let* ((pulls-api (magit-gh-pulls-comments-get-api))
               (response (oref (gh-pull-comments-new pulls-api user proj id comment) :data)))
          (message (format "response: %s " response))
          )))))

;;TODO: response: ((documentation_url . https://developer.github.com/v3) (message . Not Found))
(defun my-comment-delete (comment-id user proj)
  (let ((repo (magit-gh-pulls-guess-repo)))
    (when repo
      (let* ((pulls-api (magit-gh-pulls-comments-get-api))
             (response (oref (gh-pull-comments-delete pulls-api user proj comment-id) :data)))
        (message (format "response: %s " response))
        ))))

(defun magit-gh-pulls-insert-pull-comment (comment git-user proj id)
  "Insert COMMENT attributes into current buffer."
  (lexical-let ((git-user git-user)
                (proj proj)
                (id id)
                (created-at (magit-gh-pulls-format-pull-comment-time (oref comment :created_at)))
                (comment-id (oref comment :id))
                (user (oref (oref comment :user) :login))
                (body (oref comment :body))
                ;; (path (oref comment :path))
                ;; (commit-id (oref comment :commit-id))
                ;; (original-commit-id (oref comment :original-commit-id))
                ;; (position (oref comment :position))
                ;; (original-position (oref comment :original-position))
                ;; (diff-hunk (oref comment :diff-hunk))
                )
    (progn
      (insert (format "[%s] %s" created-at user))
      (insert (format "\n[body]\n%s" body))
      ;; (insert "\npath: ")
      ;; (bff path #'(lambda (b) (my-open-revision-file path commit-id position)))
      (insert "\nactions: ")
      (bff "replay" #'(lambda (b) (my-pulls-comments-replay comment-id git-user proj id)))
      ;; (insert " ")
      ;; (bff "delete" #'(lambda (b) (my-comment-delete comment-id git-user proj)))
      )))



(defun magit-gh-comments-insert-pulls-commits-comments (user proj id)
  (let* ((api (gh-pulls-api "api" :sync t :num-retries 1 :cache (gh-cache "cache")))
         (commits (oref (gh-pulls-list-commits api user proj id) :data)))
    (dolist (commit commits)
      (let ((repo (magit-gh-pulls-guess-repo))
            (commit-sha (oref commit :sha))
            (commit-message (oref (oref commit :commit) :message))
            )
        (when repo
          (let* ((comment-api (magit-gh-comments-get-api))
                 (commit-comments (oref (gh-comments-list-commit comment-api user proj commit-sha) :data)))

            ;; (insert (format "commit: %s\n" commit-sha))
            ;; (magit-insert-section (commit)
            ;;   (magit-insert-heading "Pull Requests:")
            ;;   )

            ;; (magit-gh-pulls-insert-pull-comment)
            (dolist (comment commit-comments)
              (magit-gh-pulls-insert-pull-comment comment user proj id)
              (insert "\n\n")
              (if (equal comment (car (last commit-comments)))
                (insert "\n---\n\n")))


            ))))))


(defun magit-gh-pulls-insert-pull-comments (user proj id)
  "Insert into current buffer the comments of PR for USER, PROJ and ID."
  (let ((comments (magit-gh-pulls-pull-comments-entries user proj id)))
    (when (> (length comments) 0)
      (insert (format "Comments (%s):\n\n" (length comments)))
      (dolist (comment comments)
        (message (format "comment: %s " comment))
        (magit-gh-pulls-insert-pull-comment comment user proj id)
        (unless (equal comment (car (last comments)))
          (insert "\n---\n\n"))))))



(defun magit-gh-pulls-cleanup-carriage-return ()
  "Remove ^M from current buffer."
  (beginning-of-buffer)
  (replace-regexp "" "")
  (beginning-of-buffer))

(defun magit-gh-pulls-insert-pull-info (user proj id)
  "Insert info about PR for USER, PROJ and ID into current buffer."
  (let* ((api (magit-gh-pulls-get-api))
         (req (oref (gh-pulls-get api user proj id) :data))
         (title (oref req :title))
         (body (or (oref req :body) "No description provided.")))
    (insert (format "#%s - %s\n\n%s\n\n" id title body))

    (magit-gh-comments-insert-pulls-commits-comments user proj id)
    ;; (magit-gh-pulls-insert-pull-comments user proj id)
    (magit-gh-pulls-cleanup-carriage-return)
    ))

(defun magit-gh-pulls-switch-to-pull-buffer (user proj id)
  "Switch to the PR buffer with name composed by USER, PROJ AND ID."
  (let ((buffer-p (magit-gh-pulls-pull-buffer user proj id))
        (buffer (get-buffer-create (magit-gh-pulls-pull-buffer-name user proj id))))
    (pop-to-buffer buffer)
    (unless buffer-p
      (magit-gh-pulls-insert-pull-info user proj id)
      (beginning-of-buffer)
      (magit-gh-comments-view-all))))

(defun magit-gh-comments-view-all ()
  "View PR info."
  (interactive)
  (let ((info (magit-section-value (magit-current-section))))
    (magit-section-case
      (unfetched-pull (apply `magit-gh-pulls-switch-to-pull-buffer info))
      (pull (apply `magit-gh-pulls-switch-to-pull-buffer info))
      (invalid-pull
       (error magit-gh-pulls-invalid-pr-ref-err)))))






(defun magit-gh-current-revision (current)
  (cond ((derived-mode-p 'magit-revision-mode)
         (car magit-refresh-args))
        ((derived-mode-p 'magit-diff-mode)
         (--when-let (car magit-refresh-args)
           (and (string-match "\\.\\.\\([^.].*\\)?[ \t]*\\'" it)
                (match-string 1 it))))))

(defun magit-gh-current-hunk (current)
  (pcase (magit-diff-scope)
    ((or `hunk `region) current)
    ((or `file `files)  (car (magit-section-children current)))
    (`list (car (magit-section-children
                 (car (magit-section-children current)))))))

(defun magit-gh-diff-position (section)
  (let* ((parent-section (magit-section-parent section))
         (cpos (marker-position (magit-section-content parent-section)))
         (cstart (save-excursion (goto-char cpos) (line-number-at-pos)))
         (stop (line-number-at-pos)))
    (- stop cstart)))

(defun magit-gh-comments-comment-commit-at-point (file &optional other-window)
  (interactive (list (or (magit-file-at-point)
                         (user-error "No file at point"))
                     current-prefix-arg))

  (let* ((current (magit-current-section))
         (repo-info (magit-gh-pulls-guess-repo))
         (hunk (magit-gh-current-hunk current)))
    (when (and repo-info hunk)
      (let* ((owner (car repo-info))
             (repo (cdr repo-info))
             (rev (magit-gh-current-revision current))
             (position (magit-gh-diff-position current))
             (api (magit-gh-comments-get-api))
             (body (read-from-minibuffer "Create line comment: "))
             (comment (make-instance 'gh-comments-comment :body body :path file :position position)))
        (message (format "=> %s" position))
        (let ((response (oref (gh-comments-new api owner repo rev comment) :data)))
          (message (format "response: ok"))) ;TODO: add error handling
        ))))


(defun magit-gh-comments-comment-commit ()
  (interactive)
  (let ((repo-info (magit-gh-pulls-guess-repo)))
    (when repo
      (let* ((current (magit-current-section))
             (owner (car repo-info))
             (repo (cdr repo-info))
             (rev (magit-gh-current-revision current))
             (api (magit-gh-comments-get-api))
             (body (read-from-minibuffer "Create: "))
             (comment (make-instance 'gh-comments-comment :body body))
             (response (oref (gh-comments-new api owner repo rev comment) :data)))
        (message (format "response: ok"))) ;; TODO: add error handling
      )))

(defun magit-gh-comments-comment-list ()
  (interactive)
  (let ((repo (magit-gh-pulls-guess-repo)))
    (when repo
      (let* ((current (magit-current-section))
             (user (car repo))
             (proj (cdr repo))
             (rev (magit-gh-current-revision current))
             (api (magit-gh-comments-get-api))
             (commit-comments (oref (gh-comments-list-commit api user proj rev) :data))
             (buffer (get-buffer-create (format "*magit-gh-comments-commit-%s-%s-#%s" user proj rev))))

        (pop-to-buffer buffer)
        (insert (format "Comments for commit: %s\n\n" rev))
        (dolist (comment commit-comments)
          (magit-gh-pulls-insert-pull-comment comment user proj rev)
          (insert "\n\n")
          (if (equal comment (car (last commit-comments)))
              (insert "\n---\n\n")))

        (beginning-of-buffer)
      ))))


(provide 'magit-gh-comments)
