
;; title: CharityVote
;; version: 1.0.0
;; summary: A transparent system for community-driven charitable donations and cause prioritization
;; description: Allows users to submit charity causes, vote on them, and distribute donations based on community preferences

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-voted (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-cause-inactive (err u105))
(define-constant err-unauthorized (err u106))

;; data vars
(define-data-var next-cause-id uint u1)
(define-data-var total-donations uint u0)
(define-data-var voting-period uint u144) ;; approximately 1 day in blocks

;; data maps
(define-map causes
  uint
  {
    title: (string-utf8 100),
    description: (string-utf8 500),
    recipient: principal,
    creator: principal,
    votes: uint,
    donations-received: uint,
    is-active: bool,
    created-at: uint
  }
)

(define-map user-votes
  { user: principal, cause-id: uint }
  { voted: bool, block-height: uint }
)

(define-map user-donations
  { user: principal, cause-id: uint }
  uint
)

(define-map cause-voters
  uint
  (list 1000 principal)
)

;; public functions

;; Submit a new charity cause
(define-public (submit-cause (title (string-utf8 100)) (description (string-utf8 500)) (recipient principal))
  (let
    (
      (cause-id (var-get next-cause-id))
    )
    (asserts! (> (len title) u0) err-invalid-amount)
    (asserts! (> (len description) u0) err-invalid-amount)

    (map-set causes cause-id
      {
        title: title,
        description: description,
        recipient: recipient,
        creator: tx-sender,
        votes: u0,
        donations-received: u0,
        is-active: true,
        created-at: block-height
      }
    )

    (var-set next-cause-id (+ cause-id u1))
    (ok cause-id)
  )
)

;; Vote for a charity cause
(define-public (vote-for-cause (cause-id uint))
  (let
    (
      (cause (unwrap! (map-get? causes cause-id) err-not-found))
      (user-vote-key { user: tx-sender, cause-id: cause-id })
      (existing-vote (map-get? user-votes user-vote-key))
      (current-voters (default-to (list) (map-get? cause-voters cause-id)))
    )
    (asserts! (get is-active cause) err-cause-inactive)
    (asserts! (is-none existing-vote) err-already-voted)

    ;; Record the vote
    (map-set user-votes user-vote-key
      { voted: true, block-height: block-height }
    )

    ;; Update cause votes
    (map-set causes cause-id
      (merge cause { votes: (+ (get votes cause) u1) })
    )

    ;; Add voter to the cause voters list (if space available)
    (if (< (len current-voters) u1000)
      (map-set cause-voters cause-id
        (unwrap-panic (as-max-len? (append current-voters tx-sender) u1000))
      )
      true
    )

    (ok true)
  )
)

;; Donate to a specific cause
(define-public (donate-to-cause (cause-id uint) (amount uint))
  (let
    (
      (cause (unwrap! (map-get? causes cause-id) err-not-found))
      (user-donation-key { user: tx-sender, cause-id: cause-id })
      (existing-donation (default-to u0 (map-get? user-donations user-donation-key)))
    )
    (asserts! (get is-active cause) err-cause-inactive)
    (asserts! (> amount u0) err-invalid-amount)

    ;; Transfer STX to the contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

    ;; Update donation records
    (map-set user-donations user-donation-key (+ existing-donation amount))

    ;; Update cause donations
    (map-set causes cause-id
      (merge cause { donations-received: (+ (get donations-received cause) amount) })
    )

    ;; Update total donations
    (var-set total-donations (+ (var-get total-donations) amount))

    (ok true)
  )
)

;; Distribute funds to a cause recipient (can be called by anyone)
(define-public (distribute-funds (cause-id uint))
  (let
    (
      (cause (unwrap! (map-get? causes cause-id) err-not-found))
      (amount (get donations-received cause))
    )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (get is-active cause) err-cause-inactive)

    ;; Transfer funds to the recipient
    (try! (as-contract (stx-transfer? amount tx-sender (get recipient cause))))

    ;; Update the cause to reflect distribution
    (map-set causes cause-id
      (merge cause { donations-received: u0 })
    )

    (ok amount)
  )
)

;; Deactivate a cause (only owner or creator can call)
(define-public (deactivate-cause (cause-id uint))
  (let
    (
      (cause (unwrap! (map-get? causes cause-id) err-not-found))
    )
    (asserts! (or (is-eq tx-sender contract-owner) (is-eq tx-sender (get creator cause))) err-unauthorized)

    (map-set causes cause-id
      (merge cause { is-active: false })
    )
    (ok true)
  )
)

;; read only functions

;; Get cause details
(define-read-only (get-cause (cause-id uint))
  (map-get? causes cause-id)
)

;; Get user vote status for a cause
(define-read-only (get-user-vote (user principal) (cause-id uint))
  (map-get? user-votes { user: user, cause-id: cause-id })
)

;; Get user donation amount for a cause
(define-read-only (get-user-donation (user principal) (cause-id uint))
  (default-to u0 (map-get? user-donations { user: user, cause-id: cause-id }))
)

;; Get total donations
(define-read-only (get-total-donations)
  (var-get total-donations)
)

;; Get next cause ID
(define-read-only (get-next-cause-id)
  (var-get next-cause-id)
)

;; Get voting period
(define-read-only (get-voting-period)
  (var-get voting-period)
)

;; Get cause voters list
(define-read-only (get-cause-voters (cause-id uint))
  (map-get? cause-voters cause-id)
)

;; Get contract owner
(define-read-only (get-contract-owner)
  contract-owner
)

;; Check if user has voted for a cause
(define-read-only (has-user-voted (user principal) (cause-id uint))
  (is-some (map-get? user-votes { user: user, cause-id: cause-id }))
)

;; Get multiple causes (for pagination)
(define-read-only (get-causes-range (start uint) (end uint))
  (let
    (
      (cause-list (list))
    )
    (fold check-and-add-cause (list start) cause-list)
  )
)

;; private functions

;; Helper function for getting multiple causes
(define-private (check-and-add-cause (cause-id uint) (acc (list 100 (optional { id: uint, cause: { title: (string-utf8 100), description: (string-utf8 500), recipient: principal, creator: principal, votes: uint, donations-received: uint, is-active: bool, created-at: uint } }))))
  (let
    (
      (cause-data (map-get? causes cause-id))
    )
    (if (is-some cause-data)
      (unwrap-panic (as-max-len? (append acc (some { id: cause-id, cause: (unwrap-panic cause-data) })) u100))
      acc
    )
  )
)
