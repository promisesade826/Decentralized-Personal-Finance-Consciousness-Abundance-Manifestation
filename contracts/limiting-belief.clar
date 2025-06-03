;; Limiting Belief Contract
;; Transforms consciousness abundance limiting beliefs

(define-constant ERR_NOT_FOUND (err u400))
(define-constant ERR_ALREADY_TRANSFORMED (err u401))

;; Data structures
(define-map limiting-beliefs
  { user: principal, belief-id: uint }
  {
    belief-description: (string-ascii 200),
    intensity-level: uint,
    transformation-affirmation: (string-ascii 200),
    status: (string-ascii 20),
    created-date: uint,
    transformed-date: (optional uint)
  }
)

(define-map belief-transformations
  { user: principal }
  {
    total-beliefs: uint,
    transformed-beliefs: uint,
    transformation-rate: uint,
    consciousness-shift: uint
  }
)

(define-data-var next-belief-id uint u1)

;; Public functions
(define-public (identify-limiting-belief
  (description (string-ascii 200))
  (intensity uint)
  (affirmation (string-ascii 200)))
  (let
    (
      (belief-id (var-get next-belief-id))
      (current-stats (default-to
        { total-beliefs: u0, transformed-beliefs: u0, transformation-rate: u0, consciousness-shift: u0 }
        (map-get? belief-transformations { user: tx-sender })))
    )
    (map-set limiting-beliefs
      { user: tx-sender, belief-id: belief-id }
      {
        belief-description: description,
        intensity-level: intensity,
        transformation-affirmation: affirmation,
        status: "identified",
        created-date: block-height,
        transformed-date: none
      }
    )
    (map-set belief-transformations
      { user: tx-sender }
      (merge current-stats { total-beliefs: (+ (get total-beliefs current-stats) u1) })
    )
    (var-set next-belief-id (+ belief-id u1))
    (ok belief-id)
  )
)

(define-public (transform-belief (belief-id uint))
  (let
    (
      (belief (unwrap! (map-get? limiting-beliefs { user: tx-sender, belief-id: belief-id }) ERR_NOT_FOUND))
      (current-stats (unwrap! (map-get? belief-transformations { user: tx-sender }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq (get status belief) "identified") ERR_ALREADY_TRANSFORMED)
    (map-set limiting-beliefs
      { user: tx-sender, belief-id: belief-id }
      (merge belief {
        status: "transformed",
        transformed-date: (some block-height)
      })
    )
    (let ((new-transformed (+ (get transformed-beliefs current-stats) u1)))
      (map-set belief-transformations
        { user: tx-sender }
        (merge current-stats {
          transformed-beliefs: new-transformed,
          transformation-rate: (/ (* new-transformed u100) (get total-beliefs current-stats)),
          consciousness-shift: (+ (get consciousness-shift current-stats) u10)
        })
      )
    )
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-limiting-belief (user principal) (belief-id uint))
  (map-get? limiting-beliefs { user: user, belief-id: belief-id })
)

(define-read-only (get-transformation-stats (user principal))
  (map-get? belief-transformations { user: user })
)

(define-read-only (get-consciousness-shift (user principal))
  (match (map-get? belief-transformations { user: user })
    stats (get consciousness-shift stats)
    u0
  )
)
