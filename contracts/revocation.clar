;; Revocation Contract
;; Handles termination of delegated rights

(define-map revocations
  { delegation-id: uint }
  { revoked: bool, revoked-at: (optional uint), reason: (optional (string-ascii 50)) })

;; Error codes
(define-constant err-already-revoked (err u500))
(define-constant err-not-revoked (err u501))
(define-constant err-unauthorized (err u502))

;; Revoke a delegation
(define-public (revoke-delegation
                (delegation-id uint)
                (reason (optional (string-ascii 50))))
  (begin
    ;; In a real implementation, we would check if the caller is authorized to revoke
    (match (map-get? revocations { delegation-id: delegation-id })
      existing-revocation (if (get revoked existing-revocation)
                             err-already-revoked
                             (ok (map-set revocations
                                         { delegation-id: delegation-id }
                                         { revoked: true,
                                           revoked-at: (some block-height),
                                           reason: reason })))
      (ok (map-set revocations
                  { delegation-id: delegation-id }
                  { revoked: true,
                    revoked-at: (some block-height),
                    reason: reason })))))

;; Check if a delegation is revoked
(define-read-only (is-revoked (delegation-id uint))
  (match (map-get? revocations { delegation-id: delegation-id })
    revocation (get revoked revocation)
    false))

;; Get revocation details
(define-read-only (get-revocation-details (delegation-id uint))
  (map-get? revocations { delegation-id: delegation-id }))
