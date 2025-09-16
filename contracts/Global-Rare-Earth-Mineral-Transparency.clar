(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-params (err u103))
(define-constant err-not-authorized (err u104))
(define-constant err-invalid-status (err u105))

(define-data-var next-mine-id uint u1)
(define-data-var next-batch-id uint u1)
(define-data-var next-shipment-id uint u1)

(define-map mines 
    { mine-id: uint }
    {
        owner: principal,
        name: (string-ascii 100),
        location: (string-ascii 100),
        mineral-type: (string-ascii 50),
        verified: bool,
        esg-score: uint,
        created-at: uint
    }
)

(define-map mineral-batches
    { batch-id: uint }
    {
        mine-id: uint,
        quantity: uint,
        mineral-type: (string-ascii 50),
        extraction-date: uint,
        current-owner: principal,
        status: (string-ascii 20),
        esg-compliance: bool,
        created-at: uint
    }
)

(define-map shipments
    { shipment-id: uint }
    {
        batch-id: uint,
        from-location: (string-ascii 100),
        to-location: (string-ascii 100),
        carrier: principal,
        status: (string-ascii 20),
        iot-device-id: (string-ascii 50),
        temperature: int,
        humidity: int,
        created-at: uint,
        updated-at: uint
    }
)

(define-map batch-history
    { batch-id: uint, sequence: uint }
    {
        owner: principal,
        action: (string-ascii 50),
        timestamp: uint,
        location: (string-ascii 100)
    }
)

(define-map authorized-verifiers principal bool)

(define-map authorized-certifiers principal bool)

(define-map batch-certifications
    { batch-id: uint, certifier: principal }
    {
        certification-data: (string-ascii 200),
        certified-at: uint
    }
)

(define-public (register-mine 
    (name (string-ascii 100))
    (location (string-ascii 100)) 
    (mineral-type (string-ascii 50)))
    (let ((mine-id (var-get next-mine-id)))
        (asserts! (> (len name) u0) err-invalid-params)
        (asserts! (> (len location) u0) err-invalid-params)
        (asserts! (> (len mineral-type) u0) err-invalid-params)
        (map-set mines 
            { mine-id: mine-id }
            {
                owner: tx-sender,
                name: name,
                location: location,
                mineral-type: mineral-type,
                verified: false,
                esg-score: u0,
                created-at: stacks-block-height
            }
        )
        (var-set next-mine-id (+ mine-id u1))
        (ok mine-id)
    )
)

(define-public (verify-mine (mine-id uint) (esg-score uint))
    (let ((mine (unwrap! (map-get? mines { mine-id: mine-id }) err-not-found)))
        (asserts! (or (is-eq tx-sender contract-owner) 
                     (default-to false (map-get? authorized-verifiers tx-sender))) 
                 err-not-authorized)
        (asserts! (<= esg-score u100) err-invalid-params)
        (map-set mines 
            { mine-id: mine-id }
            (merge mine { verified: true, esg-score: esg-score })
        )
        (ok true)
    )
)

(define-public (create-mineral-batch 
    (mine-id uint) 
    (quantity uint) 
    (mineral-type (string-ascii 50)))
    (let ((batch-id (var-get next-batch-id))
          (mine (unwrap! (map-get? mines { mine-id: mine-id }) err-not-found)))
        (asserts! (is-eq tx-sender (get owner mine)) err-not-authorized)
        (asserts! (get verified mine) err-invalid-status)
        (asserts! (> quantity u0) err-invalid-params)
        (map-set mineral-batches 
            { batch-id: batch-id }
            {
                mine-id: mine-id,
                quantity: quantity,
                mineral-type: mineral-type,
                extraction-date: stacks-block-height,
                current-owner: tx-sender,
                status: "extracted",
                esg-compliance: (>= (get esg-score mine) u70),
                created-at: stacks-block-height
            }
        )
        (map-set batch-history
            { batch-id: batch-id, sequence: u0 }
            {
                owner: tx-sender,
                action: "extracted",
                timestamp: stacks-block-height,
                location: (get location mine)
            }
        )
        (var-set next-batch-id (+ batch-id u1))
        (ok batch-id)
    )
)

(define-public (transfer-batch (batch-id uint) (new-owner principal) (location (string-ascii 100)))
    (let ((batch (unwrap! (map-get? mineral-batches { batch-id: batch-id }) err-not-found))
          (history-count (get-batch-history-count batch-id)))
        (asserts! (is-eq tx-sender (get current-owner batch)) err-not-authorized)
        (map-set mineral-batches 
            { batch-id: batch-id }
            (merge batch { 
                current-owner: new-owner, 
                status: "transferred" 
            })
        )
        (map-set batch-history
            { batch-id: batch-id, sequence: history-count }
            {
                owner: new-owner,
                action: "transferred",
                timestamp: stacks-block-height,
                location: location
            }
        )
        (ok true)
    )
)

(define-public (create-shipment 
    (batch-id uint)
    (from-location (string-ascii 100))
    (to-location (string-ascii 100))
    (iot-device-id (string-ascii 50)))
    (let ((shipment-id (var-get next-shipment-id))
          (batch (unwrap! (map-get? mineral-batches { batch-id: batch-id }) err-not-found)))
        (asserts! (is-eq tx-sender (get current-owner batch)) err-not-authorized)
        (asserts! (> (len from-location) u0) err-invalid-params)
        (asserts! (> (len to-location) u0) err-invalid-params)
        (map-set shipments 
            { shipment-id: shipment-id }
            {
                batch-id: batch-id,
                from-location: from-location,
                to-location: to-location,
                carrier: tx-sender,
                status: "in-transit",
                iot-device-id: iot-device-id,
                temperature: 0,
                humidity: 0,
                created-at: stacks-block-height,
                updated-at: stacks-block-height
            }
        )
        (map-set mineral-batches 
            { batch-id: batch-id }
            (merge batch { status: "in-transit" })
        )
        (var-set next-shipment-id (+ shipment-id u1))
        (ok shipment-id)
    )
)

(define-public (update-shipment-iot 
    (shipment-id uint) 
    (temperature int) 
    (humidity int))
    (let ((shipment (unwrap! (map-get? shipments { shipment-id: shipment-id }) err-not-found)))
        (asserts! (is-eq tx-sender (get carrier shipment)) err-not-authorized)
        (map-set shipments 
            { shipment-id: shipment-id }
            (merge shipment {
                temperature: temperature,
                humidity: humidity,
                updated-at: stacks-block-height
            })
        )
        (ok true)
    )
)

(define-public (complete-shipment (shipment-id uint))
    (let ((shipment (unwrap! (map-get? shipments { shipment-id: shipment-id }) err-not-found))
          (batch-id (get batch-id shipment))
          (batch (unwrap! (map-get? mineral-batches { batch-id: batch-id }) err-not-found))
          (history-count (get-batch-history-count batch-id)))
        (asserts! (is-eq tx-sender (get carrier shipment)) err-not-authorized)
        (map-set shipments 
            { shipment-id: shipment-id }
            (merge shipment { 
                status: "delivered",
                updated-at: stacks-block-height 
            })
        )
        (map-set mineral-batches 
            { batch-id: batch-id }
            (merge batch { status: "delivered" })
        )
        (map-set batch-history
            { batch-id: batch-id, sequence: history-count }
            {
                owner: (get carrier shipment),
                action: "delivered",
                timestamp: stacks-block-height,
                location: (get to-location shipment)
            }
        )
        (ok true)
    )
)

(define-public (add-authorized-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-verifiers verifier true)
        (ok true)
    )
)

(define-public (remove-authorized-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-delete authorized-verifiers verifier)
        (ok true)
    )
)

(define-public (add-authorized-certifier (certifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-certifiers certifier true)
        (ok true)
    )
)

(define-public (remove-authorized-certifier (certifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-delete authorized-certifiers certifier)
        (ok true)
    )
)

(define-public (certify-batch (batch-id uint) (certification-data (string-ascii 200)))
    (let ((batch (unwrap! (map-get? mineral-batches { batch-id: batch-id }) err-not-found)))
        (asserts! (default-to false (map-get? authorized-certifiers tx-sender)) err-not-authorized)
        (asserts! (> (len certification-data) u0) err-invalid-params)
        (map-set batch-certifications
            { batch-id: batch-id, certifier: tx-sender }
            {
                certification-data: certification-data,
                certified-at: stacks-block-height
            }
        )
        (ok true)
    )
)

(define-read-only (get-mine (mine-id uint))
    (map-get? mines { mine-id: mine-id })
)

(define-read-only (get-mineral-batch (batch-id uint))
    (map-get? mineral-batches { batch-id: batch-id })
)

(define-read-only (get-shipment (shipment-id uint))
    (map-get? shipments { shipment-id: shipment-id })
)

(define-read-only (get-batch-history-entry (batch-id uint) (sequence uint))
    (map-get? batch-history { batch-id: batch-id, sequence: sequence })
)

(define-read-only (is-authorized-verifier (verifier principal))
    (default-to false (map-get? authorized-verifiers verifier))
)

(define-read-only (get-batch-origin (batch-id uint))
    (match (map-get? mineral-batches { batch-id: batch-id })
        batch (map-get? mines { mine-id: (get mine-id batch) })
        none
    )
)

(define-read-only (is-authorized-certifier (certifier principal))
    (default-to false (map-get? authorized-certifiers certifier))
)

(define-read-only (get-batch-certification (batch-id uint) (certifier principal))
    (map-get? batch-certifications { batch-id: batch-id, certifier: certifier })
)

(define-private (get-batch-history-count (batch-id uint))
    (get count (fold count-history-entries (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9) { batch-id: batch-id, count: u0 }))
)

(define-private (count-history-entries (sequence uint) (state { batch-id: uint, count: uint }))
    (let ((batch-id (get batch-id state))
          (current-count (get count state)))
        (if (is-some (map-get? batch-history { batch-id: batch-id, sequence: sequence }))
            { batch-id: batch-id, count: (+ current-count u1) }
            state
        )
    )
)
;;