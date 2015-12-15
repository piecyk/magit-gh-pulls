(require 'eieio)

(require 'magit)
(require 'gh)
(require 'gh-pulls)
(require 'gh-repos)
(require 'gh-pull-comments)
(require 'gh-issue-comments)
(require 'pcache)
(require 's)


;; (defun magit-gh-comments-buffer-name (user proj id)
;;   "Compose name of Comments buffer with USER, PROJ and pr ID."
;;   (format "*magit-gh-comments-%s-%s-#%s" user proj id))

;; (defun magit-gh-comments-get-buffer (user proj id)
;;   "Return PR buffer for USER,PROJ and ID if it exists."
;;   (get-buffer (magit-gh-comments-buffer-name user proj id)))


;; (defun magit-gh-comments-cache-invalidate (cache repo)
;;   (pcache-map cache (lambda (k v)
;;                       (when (string-match
;;                              (format "/repos/%s/%s/" (car repo) (cdr repo))
;;                              (car k))
;;                         (pcache-invalidate cache k)))))

;; (defun magit-gh-comments-invalidate ()
;;   (let* ((repo (magit-gh-pulls-guess-repo))
;;          (pulls-api (magit-gh-pulls-get-api))
;;          ;; (comments-api (magit-gh-comments-get-api))
;;          (issue-comments-api (magit-gh-comments-issue-comments-get-api))
;;          (pull-comments-api (magit-gh-comments-pull-comments-get-api)))

;;     ;; (magit-gh-comments-cache-invalidate (oref pulls-api :cache) repo)
;;     ;; (magit-gh-comments-cache-invalidate (oref comments-api :cache) repo)
;;     (magit-gh-comments-cache-invalidate (oref issue-comments-api :cache) repo)
;;     (magit-gh-comments-cache-invalidate (oref pull-comments-api :cache) repo)
;;     ))

;; TODO: add actions: edit, add/add line comment so replay, delete
;; actions will need different data when pull, issue, commit comments
;; when showing pull or commit comments include a path to magit-diff and show the line was commented
;; TODO: use magit sections, toggle commit body etc for better user expiration
;; (defun insert-simple-comments (comments)
;;   (dolist (comment comments)
;;     (lexical-let ((created-at (magit-gh-comments-format-time (oref comment :created_at)))
;;                   (user (oref (oref comment :user) :login))
;;                   (body (oref comment :body)))
;;       (progn
;;         (insert (format "[%s] %s" created-at user))
;;         (insert (format "\n[body]\n%s\n\n" body))
;;         ))))

;; (defun magit-gh-comments-insert-pull-info (user proj id)
;;   "Insert info about PR for USER, PROJ and ID into current buffer."
;;   (let* ((api (magit-gh-pulls-get-api))
;;          (req (oref (gh-pulls-get api user proj id) :data))
;;          (title (oref req :title))
;;          (body (or (oref req :body) "No description provided.")))
;;     (insert (format "#%s - %s\n\n%s\n" id title body))))

;; (defun magit-gh-comments-insert-pull-comments (user proj id)
;;   (let ((repo (magit-gh-pulls-guess-repo)))
;;     (when repo
;;       (let* ((api (magit-gh-comments-pull-comments-get-api))
;;              (comments (oref (gh-pull-comments-list api user proj id) :data)))
;;         (insert (format "*Pull comments (%s)\n\n" (length comments)))
;;         (insert-simple-comments comments)
;;         ))))

;; (defun magit-gh-comments-insert-issue-comments (user proj id)
;;   (let ((repo (magit-gh-pulls-guess-repo)))
;;     (when repo
;;       (let* ((api (magit-gh-comments-issue-comments-get-api))
;;              (comments (oref (gh-issue-comments-list api user proj id) :data)))
;;         (insert (format "*Issue comments (%s)\n\n" (length comments)))
;;         (insert-simple-comments comments)
;;         ))))



;; (require 'button)
;; (defun bff (label action)
;;   (insert-text-button label 'follow-link t 'action action))

;; (defun my-open-revision-file (path commit-id position)
;;   ;; open here commit in magit diff
;;   (magit-find-file-other-window commit-id path)
;;   (interactive)
;;   (with-no-warnings
;;     (goto-line position)))

;; (defun magit-gh-comments-insert-commits-comments (user proj id)
;;   (let ((repo (magit-gh-pulls-guess-repo)))
;;     (when repo
;;       (let* ((pulls-api (magit-gh-pulls-get-api))
;;              (repos-api (magit-gh-comments-repos-get-api))
;;              (commits (oref (gh-pulls-list-commits pulls-api user proj id) :data))
;;              comments)

;;         (magit-insert-section (commit-comments)
;;           (magit-insert-heading "Commits comments:")

;;           (when (> (length commits) 0)

;;             (dolist (commit commits)
;;               (let* ((commit-sha (oref commit :sha))
;;                      (c-comments (oref (gh-repos-comments-list-commit repos-api user proj commit-sha) :data)))
;;                 (setq comments (append comments c-comments))))

;;             ;; (insert (format "*Commits comments (%s)\n\n" (length comments)))
;;             (dolist (comment comments)
;;               (lexical-let ((created-at (magit-gh-comments-format-time (oref comment :created_at)))
;;                             (user (oref (oref comment :user) :login))
;;                             (body (oref comment :body))
;;                             (path (oref comment :path))
;;                             (commit-id (oref comment :commit-id))
;;                             (line (oref comment :line))
;;                             (position "1"))

;;                 (magit-insert-section
;;                   (commit-comments)
;;                   (insert (format "[%s] %s\n" created-at user))
;;                   (insert (format "sha: %s\n" commit-id))
;;                   (bff path #'(lambda (b) (my-open-revision-file path commit-id line)))
;;                   (insert (format "\nbody: \n%s\n\n" body))
;;                   (magit-insert-heading)
;;                   )))
;;             ))

;;         ))))

;; (defun magit-gh-comments-switch-to-comments-all-buffer (user proj id)
;;   "Switch to the PR buffer with name composed by USER, PROJ AND ID."
;;   (lexical-let ((user user) (proj proj) (id id)
;;                 (buffer-p (magit-gh-comments-get-buffer user proj id))
;;                 (buffer (get-buffer-create (magit-gh-comments-buffer-name user proj id))))
;;     (pop-to-buffer buffer)
;;     (unless buffer-p
;;       (message "start")
;;       (magit-gh-comments-insert-pull-info user proj id)
;;       (insert "\n\n")
;;       (magit-gh-comments-insert-pull-comments user proj id)
;;       (insert "\n\n")
;;       (magit-gh-comments-insert-issue-comments user proj id)
;;       (insert "\n\n")
;;       (magit-gh-comments-insert-commits-comments user proj id)

;;       (magit-gh-comments-cleanup-carriage-return)
;;       (beginning-of-buffer)
;;       (local-set-key (kbd "q") 'kill-this-buffer)
;;       ;;TODO: we want to refresh comments quick, wip
;;       (local-set-key (kbd "g") (lambda ()
;;                                  (interactive)
;;                                  ;; (magit-gh-comments-invalidate)
;;                                  ;; remove jumping, erase buffer and write to it again
;;                                  ;; (kill-buffer buffer)
;;                                  ;; (magit-gh-comments-switch-to-comments-all-buffer user proj id)
;;                                  ))
;;       ;;TODO: make the buffer ui better re-use magit sections
;;       ;; (read-only-mode)
;;       )))

;; (defun magit-gh-current-revision (current)
;;   (cond ((derived-mode-p 'magit-revision-mode)
;;          (car magit-refresh-args))
;;         ((derived-mode-p 'magit-diff-mode)
;;          (--when-let (car magit-refresh-args)
;;            (and (string-match "\\.\\.\\([^.].*\\)?[ \t]*\\'" it)
;;                 (match-string 1 it))))))

;; (defun magit-gh-current-hunk (current)
;;   (pcase (magit-diff-scope)
;;     ((or `hunk `region) current)
;;     ((or `file `files)  (car (magit-section-children current)))
;;     (`list (car (magit-section-children
;;                  (car (magit-section-children current)))))))

;; (defun magit-gh-diff-position (section)
;;   (let* ((parent-section (magit-section-parent section))
;;          (cpos (marker-position (magit-section-content parent-section)))
;;          (cstart (save-excursion (goto-char cpos) (line-number-at-pos)))
;;          (stop (line-number-at-pos)))
;;     (- stop cstart)))


;; ;;TODO: add confirmation before send ( yes, no, edit )
;; ;;TODO: change minibuffer to buffer
;; ;;TODO: add error handling when fail and re-try
;; (defun magit-gh-comments-comment-commit-at-point (file &optional other-window)
;;   "Add comment to commit on specific position. Use this in magit-diff mode
;; on line you want to comment"
;;   (interactive (list (or (magit-file-at-point)
;;                          (user-error "No file at point"))
;;                      current-prefix-arg))

;;   (let* ((current (magit-current-section))
;;          (repo-info (magit-gh-pulls-guess-repo))
;;          (hunk (magit-gh-current-hunk current)))
;;     (when (and repo-info hunk)
;;       (let* ((owner (car repo-info))
;;              (repo (cdr repo-info))
;;              (rev (magit-gh-current-revision current))
;;              (position (magit-gh-diff-position current))
;;              (api (magit-gh-comments-repos-get-api))
;;              (body (read-from-minibuffer "Create line comment: "))
;;              (comment (make-instance 'gh-repos-comment :body body :path file :position position)))

;;         (let ((response (oref (gh-repos-comments-new api owner repo rev comment) :data)))
;;           (message (format "response: ok"))) ;TODO: add error handling

;;         ))))

;; ;;TODO: add confirmation before send ( yes, no, edit )
;; ;;TODO: change minibuffer to buffer
;; ;;TODO: add error handling when fail and re-try
;; (defun magit-gh-comments-comment-commit ()
;;   "Add comment to commit use this in magit-diff mode"
;;   (interactive)
;;   (let ((repo-info (magit-gh-pulls-guess-repo)))
;;     (when repo
;;       (let* ((current (magit-current-section))
;;              (owner (car repo-info))
;;              (repo (cdr repo-info))
;;              (rev (magit-gh-current-revision current))
;;              (api (magit-gh-comments-repos-get-api))
;;              (body (read-from-minibuffer "Create: "))
;;              (comment (make-instance 'gh-repos-comment :body body))
;;              (response (oref (gh-repos-comments-new api owner repo rev comment) :data)))
;;         (message (format "response: ok"))) ;; TODO: add error handling
;;       )))

;; (defun magit-gh-comments-switch-to-comments-commit-buffer (comments rev)
;;   (let* ((buffer-name (format "*magit-gh-comments-view-commit-comments-#%s" rev))
;;          (buffer-p (get-buffer buffer-name))
;;          (buffer (get-buffer-create buffer-name)))
;;     (pop-to-buffer buffer)
;;     (unless buffer-p
;;       (insert (format "*Commits comments (%s)\n" (length comments)))
;;       (insert-simple-comments comments)

;;       (beginning-of-buffer)
;;       (local-set-key (kbd "q") 'kill-this-buffer)
;;       ;;TODO: refresh on g
;;       ;;TODO: make the buffer ui better re-use magit sections
;;       (read-only-mode)
;;       )))

;; ;; also it would be nice to call this fn from magit-status, when over a commit
;; ;; then we will take rev from it, and if rev is null use magit-gh-current-revision when in
;; ;; magit-diff
;; (defun magit-gh-comments-comment-list ()
;;   "List comments for commit in magit-diff"
;;   (interactive)
;;   (let ((repo (magit-gh-pulls-guess-repo)))
;;     (when repo
;;       (let* ((rev (magit-gh-current-revision (magit-current-section)))
;;              (user (car repo))
;;              (proj (cdr repo))
;;              (api (magit-gh-comments-repos-get-api))
;;              (comments (oref (gh-comments-list-commit api user proj rev) :data)))
;;         (magit-gh-comments-switch-to-comments-commit-buffer comments rev)
;;         ))))






(defun magit-gh-comments-repos-get-api ()
  (gh-repos-api "api" :sync t :num-retries 1 :cache (gh-cache "cache")))

(defun magit-gh-comments-pull-comments-get-api ()
  (gh-pull-comments-api "api" :sync t :num-retries 1 :cache (gh-cache "cache")))

(defun magit-gh-comments-issue-comments-get-api ()
  (gh-issue-comments-api "api" :sync t :num-retries 1 :cache (gh-cache "cache")))


(defun magit-gh-comments-cleanup-carriage-return ()
  "Remove ^M from current buffer."
  (beginning-of-buffer)
  (replace-regexp "" "")
  (beginning-of-buffer))

(defun magit-gh-comments-format-time (time)
  "Format TIME with 'nice' style for comments."
  (let ((format "%d/%m/%Y %H:%M:%S"))
    (format-time-string format (date-to-time time))))


(defun magit-gh-comments-view-file ()
  (interactive)
  (let ((comment (magit-section-value (magit-current-section))))
    (magit-find-file-other-window (oref comment :commit-id)
                                  (oref comment :path))))

(magit-define-popup magit-gh-comments-popup
  'magit-commands
  :actions  '((?g "Reload" magit-gh-pulls-reload)
              (?v "View file" magit-gh-comments-view-file)))

(defvar magit-gh-comments-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "@") 'magit-gh-comments-popup)
    map))

(define-derived-mode magit-gh-comments-mode magit-mode "Magit Github Comments"
  :group 'magit-gh-comments
  :keymap 'magit-gh-comments-mode-map
  (hack-dir-local-variables-non-file-buffer))

(defcustom magit-gh-comments-mode-hook nil
  "Hook run after entering magit-gh-comments mode."
  :group 'magit-gh-comments
  :type 'hook)


(defun magit-gh-comments-insert-pull-comments (user proj id)
  (let* ((api (magit-gh-comments-pull-comments-get-api))
         (comments (oref (gh-pull-comments-list api user proj id) :data)))
    (dolist (comment comments)
      (lexical-let ((created-at (magit-gh-comments-format-time (oref comment :created_at)))
                    (user (oref (oref comment :user) :login))
                    (body (oref comment :body))
                    (commit-id (oref comment :commit-id))
                    (diff-hunk (oref comment :diff-hunk))
                    (path (oref comment :path))
                    (original-position (oref comment :original-position))
                    (position (oref comment :position))
                    )

        (magit-insert-section (gh-comments-pull comment)
          (magit-insert-heading (format " [%s] %s\n" created-at user))
          (insert (format " path              : %s\n" path))
          (insert (format " original-position : %s\n" original-position))
          (insert (format " postion           : %s\n" position))
          (magit-insert-section (gh-comments-pull-diff nil t)
            (magit-insert-heading " diff:\n")
            (insert (format "%s\n" diff-hunk)))
          (insert (format " body: \n%s\n\n" body))

          )))))

(defun magit-gh-comments-insert-issue-comments (user proj id)
  (let* ((api (magit-gh-comments-issue-comments-get-api))
         (comments (oref (gh-issue-comments-list api user proj id) :data)))

    (dolist (comment comments)
      (lexical-let ((created-at (magit-gh-comments-format-time (oref comment :created_at)))
                    (user (oref (oref comment :user) :login))
                    (body (oref comment :body)))

        (magit-insert-section (gh-comments-issue comment)
          (magit-insert-heading (format " [%s] %s\n" created-at user))
          (insert (format " body: \n%s\n\n" body))
          )))))

(defun magit-gh-comments-insert-commits-comments (user proj id)
  (let* ((pulls-api (magit-gh-pulls-get-api))
         (repos-api (magit-gh-comments-repos-get-api))
         (commits (oref (gh-pulls-list-commits pulls-api user proj id) :data))
         comments)

    (dolist (commit commits)
      (let* ((commit-sha (oref commit :sha))
             (c-comments (oref (gh-repos-comments-list-commit repos-api user proj commit-sha) :data)))
        (setq comments (append comments c-comments))))
    (dolist (comment comments)
      (lexical-let ((created-at (magit-gh-comments-format-time (oref comment :created_at)))
                    (user (oref (oref comment :user) :login))
                    (body (oref comment :body))
                    (path (oref comment :path))
                    (commit-id (oref comment :commit-id))
                    (line (oref comment :line))
                    (position (oref comment :position)))

        (magit-insert-section (gh-comments-commit comment)
          (magit-insert-heading (format " [%s] %s\n" created-at user))
          (insert (format " path:    %s\n" path))
          (insert (format " postion: %s\n" position))
          (insert (format " body: \n%s\n\n" body))
          )))
    ))


(defun magit-gh-comments-refresh-buffer (info)
  (magit-insert-section (gh-comments-buf)

    (magit-insert-section (gh-comments-header)
      (magit-insert-heading "Pull requests comments header")
      (insert "\n"))

    (magit-insert-section (gh-comments-pull)
      (magit-insert-heading "Pull comments:")
      (apply `magit-gh-comments-insert-pull-comments info))

    (magit-insert-section (gh-comments-issue)
      (magit-insert-heading "Issue comments:")
      (apply `magit-gh-comments-insert-issue-comments info))

    (magit-insert-section (gh-comments-commit)
      (magit-insert-heading "Commit comments:")
      (apply `magit-gh-comments-insert-commits-comments info)))

  (magit-gh-comments-cleanup-carriage-return))


(defun magit-gh-comments-view-all ()
  (interactive)
  (let ((info (magit-section-value (magit-current-section))))
    (magit-section-case
      ;; TODO: ass support for commit
      (unfetched-pull (magit-mode-setup #'magit-gh-comments-mode info))
      (pull (magit-mode-setup #'magit-gh-comments-mode info))
      (invalid-pull
       (error "Invalid pull requests")))))


(provide 'magit-gh-comments)
;; End:
;;; magit-gh-comments.el ends here
