;; Abundance Tracking Contract
;; Monitors consciousness abundance development

(define-constant ERR_NOT_FOUND (err u300))
(define-constant ERR_INVALID_SCORE (err u301))

;; Data structures
(define-map abundance-scores
  { user: principal }
  {
    financial-abundance: uint,
    emotional-abundance: uint,
    spiritual-abundance: uint,
    total-score: uint,
    last-updated: uint,
    level: (string-ascii 20)
  }
)

(define-map daily-practices
  { user: principal, date: uint }
  {
    meditation-minutes: uint,
    gratitude-entries: uint,
    affirmations-count: uint,
    visualization-sessions: uint,
    abundance-actions: uint
  }
)

;; Public functions
(define-public (initialize-abundance-tracking)
  (begin
    (map-set abundance-scores
      { user: tx-sender }
      {
        financial-abundance: u50,
        emotional-abundance: u50,
        spiritual-abundance: u50,
        total-score: u150,
        last-updated: block-height,
        level: "beginner"
      }
    )
    (ok true)
  )
)

(define-public (update-abundance-scores
  (financial uint)
  (emotional uint)
  (spiritual uint))
  (let
    (
      (total (+ financial (+ emotional spiritual)))
      (level (if (>= total u240) "master"
               (if (>= total u180) "advanced"
                 (if (>= total u120) "intermediate" "beginner"))))
    )
    (asserts! (and (<= financial u100) (<= emotional u100) (<= spiritual u100)) ERR_INVALID_SCORE)
    (map-set abundance-scores
      { user: tx-sender }
      {
        financial-abundance: financial,
        emotional-abundance: emotional,
        spiritual-abundance: spiritual,
        total-score: total,
        last-updated: block-height,
        level: level
      }
    )
    (ok true)
  )
)

(define-public (log-daily-practice
  (meditation uint)
  (gratitude uint)
  (affirmations uint)
  (visualization uint)
  (actions uint))
  (begin
    (map-set daily-practices
      { user: tx-sender, date: block-height }
      {
        meditation-minutes: meditation,
        gratitude-entries: gratitude,
        affirmations-count: affirmations,
        visualization-sessions: visualization,
        abundance-actions: actions
      }
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-abundance-scores (user principal))
  (map-get? abundance-scores { user: user })
)

(define-read-only (get-daily-practice (user principal) (date uint))
  (map-get? daily-practices { user: user, date: date })
)

(define-read-only (get-abundance-level (user principal))
  (match (map-get? abundance-scores { user: user })
    scores (get level scores)
    "not-initialized"
  )
)
