;; ClaimBoard - Decentralized insurance claims
(define-constant ERR-NOT-ADJUSTER (err u100))
(define-constant ERR-ALREADY-APPROVED (err u101))

(define-map claims
    { claim-id: uint }
    { claimant: principal, policy-id: (buff 32), amount: uint, evidence: (string-ascii 256), approvals: uint, settled: bool }
)

(define-map claim-approvers { claim-id: uint, adjuster: principal } { approved: bool })
(define-map adjusters { adjuster: principal } { is-adjuster: bool })
(define-data-var claim-counter uint u0)
(define-data-var approval-threshold uint u2)

(define-public (file-claim (policy-id (buff 32)) (amount uint) (evidence (string-ascii 256)))
    (let (
        (claim-id (var-get claim-counter))
    )
        (map-set claims { claim-id: claim-id } {
            claimant: tx-sender,
            policy-id: policy-id,
            amount: amount,
            evidence: evidence,
            approvals: u0,
            settled: false
        })
        (var-set claim-counter (+ claim-id u1))
        (ok claim-id)
    )
)

(define-public (approve-claim (claim-id uint))
    (let (
        (claim (unwrap! (map-get? claims { claim-id: claim-id }) ERR-NOT-ADJUSTER))
        (already-approved (default-to false (get approved (map-get? claim-approvers { claim-id: claim-id, adjuster: tx-sender }))))
    )
        (asserts! (default-to false (get is-adjuster (map-get? adjusters { adjuster: tx-sender }))) ERR-NOT-ADJUSTER)
        (asserts! (not already-approved) ERR-ALREADY-APPROVED)
        (map-set claim-approvers { claim-id: claim-id, adjuster: tx-sender } { approved: true })
        (let ((new-approvals (+ (get approvals claim) u1)))
            (map-set claims { claim-id: claim-id } (merge claim { approvals: new-approvals }))
            (if (>= new-approvals (var-get approval-threshold))
                (map-set claims { claim-id: claim-id } (merge claim { settled: true, approvals: new-approvals }))
                true
            )
        )
        (ok true)
    )
)

(define-read-only (get-claim (claim-id uint))
    (map-get? claims { claim-id: claim-id })
)
