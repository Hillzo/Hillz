;; DeFi Exchange Smart Contract

;; Constants and Error Codes
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_INVALID_TOKEN (err u103))
(define-constant ERR_PAUSED (err u104))
(define-constant ERR_INVALID_PARAMETER (err u105))
(define-constant ERR_TOKEN_NOT_WHITELISTED (err u106))
(define-constant ERR_TOKEN_VALIDATION_FAILED (err u107))

;; SIP-010 Token Interface
(use-trait sip-010-trait .sip-010-ft-trait.sip-010-ft-trait)

;; Data Variables
(define-data-var contract-paused bool false)
(define-data-var current-gas-price uint u10)
(define-data-var fee-percentage uint u1) ;; 0.1% fee
(define-data-var accumulated-fees uint u0)

;; Data Maps
(define-map balances {user: principal, token: principal} uint)
(define-map allowances {owner: principal, spender: principal, token: principal} uint)
(define-map whitelisted-tokens principal bool)

;; Events
(define-data-var last-event-id uint u0)

(define-private (emit-event (event-type (string-ascii 50)) (data (tuple (event-data int))))
  (let ((event-id (+ (var-get last-event-id) u1)))
    (var-set last-event-id event-id)
    (print {event-id: event-id, event-type: event-type, data: data})
  )
)

;; Read-only Functions
(define-read-only (get-contract-state)
  (ok (var-get contract-paused))
)

(define-read-only (get-current-gas-price)
  (ok (var-get current-gas-price))
)

(define-read-only (get-fee-percentage)
  (ok (var-get fee-percentage))
)

(define-read-only (get-accumulated-fees)
  (ok (var-get accumulated-fees))
)

(define-read-only (get-balance (user principal) (token <sip-010-trait>))
  (ok (default-to u0 (map-get? balances {user: user, token: (contract-of token)})))
)

(define-read-only (get-allowance (owner principal) (spender principal) (token <sip-010-trait>))
  (ok (default-to u0 (map-get? allowances {owner: owner, spender: spender, token: (contract-of token)})))
)

(define-read-only (is-token-whitelisted (token <sip-010-trait>))
  (ok (default-to false (map-get? whitelisted-tokens (contract-of token))))
)

;; Private Functions
(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT_OWNER)
)

(define-private (is-valid-token (token <sip-010-trait>))
  (begin
    (try! (contract-call? token get-name))
    (try! (contract-call? token get-symbol))
    (try! (contract-call? token get-decimals))
    (try! (contract-call? token get-balance tx-sender))
    (ok true)
  )
)

(define-private (check-token-whitelisted (token <sip-010-trait>))
  (match (map-get? whitelisted-tokens (contract-of token))
    whitelisted (if whitelisted 
                    (match (is-valid-token token)
                      success (ok true)
                      error ERR_TOKEN_VALIDATION_FAILED
                    )
                    ERR_TOKEN_NOT_WHITELISTED)
    ERR_TOKEN_NOT_WHITELISTED
  )
)

(define-private (calculate-fee (amount uint))
  (/ (* amount (var-get fee-percentage)) u1000)
)

(define-private (is-valid-principal (principal principal))
  (match (principal-destruct? principal)
    success true
    error false
  )
)

;; Public Functions
(define-public (set-contract-pause (paused bool))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (var-set contract-paused paused)
    (emit-event "contract-pause-updated" {event-data: (if paused 1 0)})
    (ok paused)
  )
)

(define-public (update-gas-price (new-price uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (> new-price u0) ERR_INVALID_PARAMETER)
    (var-set current-gas-price new-price)
    (emit-event "gas-price-updated" {event-data: (to-int new-price)})
    (ok new-price)
  )
)

(define-public (update-fee-percentage (new-percentage uint))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (asserts! (<= new-percentage u100) ERR_INVALID_PARAMETER)
    (var-set fee-percentage new-percentage)
    (emit-event "fee-percentage-updated" {event-data: (to-int new-percentage)})
    (ok new-percentage)
  )
)

(define-public (whitelist-token (token <sip-010-trait>))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (try! (is-valid-token token))
    (map-set whitelisted-tokens (contract-of token) true)
    (emit-event "token-whitelisted" {event-data: 1})
    (ok true)
  )
)

(define-public (deposit (token <sip-010-trait>) (amount uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR_PAUSED)
    (try! (check-token-whitelisted token))
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (let ((sender-balance (unwrap-panic (contract-call? token get-balance tx-sender))))
      (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
      (try! (contract-call? token transfer tx-sender (as-contract tx-sender) amount))
      (map-set balances {user: tx-sender, token: (contract-of token)} 
        (+ (default-to u0 (map-get? balances {user: tx-sender, token: (contract-of token)})) amount))
      (emit-event "deposit" {event-data: (to-int amount)})
      (ok amount)
    )
  )
)

(define-public (withdraw (token <sip-010-trait>) (amount uint))
  (let (
    (balance (default-to u0 (map-get? balances {user: tx-sender, token: (contract-of token)})))
  )
    (begin
      (asserts! (not (var-get contract-paused)) ERR_PAUSED)
      (try! (check-token-whitelisted token))
      (asserts! (>= balance amount) ERR_INSUFFICIENT_BALANCE)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (try! (as-contract (contract-call? token transfer tx-sender tx-sender amount)))
      (map-set balances {user: tx-sender, token: (contract-of token)} (- balance amount))
      (emit-event "withdraw" {event-data: (to-int amount)})
      (ok amount)
    )
  )
)

(define-public (transfer (token <sip-010-trait>) (recipient principal) (amount uint))
  (let (
    (sender-balance (default-to u0 (map-get? balances {user: tx-sender, token: (contract-of token)})))
    (fee (calculate-fee amount))
    (transfer-amount (- amount fee))
  )
    (begin
      (asserts! (not (var-get contract-paused)) ERR_PAUSED)
      (try! (check-token-whitelisted token))
      (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
      (asserts! (is-valid-principal recipient) ERR_INVALID_PARAMETER)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (map-set balances {user: tx-sender, token: (contract-of token)} (- sender-balance amount))
      (map-set balances {user: recipient, token: (contract-of token)} 
        (+ (default-to u0 (map-get? balances {user: recipient, token: (contract-of token)})) transfer-amount))
      (var-set accumulated-fees (+ (var-get accumulated-fees) fee))
      (emit-event "transfer" {event-data: (to-int amount)})
      (ok amount)
    )
  )
)

(define-public (approve (token <sip-010-trait>) (spender principal) (amount uint))
  (begin
    (asserts! (not (var-get contract-paused)) ERR_PAUSED)
    (try! (check-token-whitelisted token))
    (asserts! (is-valid-principal spender) ERR_INVALID_PARAMETER)
    (asserts! (>= amount u0) ERR_INVALID_AMOUNT)
    (map-set allowances {owner: tx-sender, spender: spender, token: (contract-of token)} amount)
    (emit-event "approve" {event-data: (to-int amount)})
    (ok amount)
  )
)

(define-public (transfer-from (token <sip-010-trait>) (owner principal) (recipient principal) (amount uint))
  (let (
    (allowance (default-to u0 (map-get? allowances {owner: owner, spender: tx-sender, token: (contract-of token)})))
    (owner-balance (default-to u0 (map-get? balances {user: owner, token: (contract-of token)})))
    (fee (calculate-fee amount))
    (transfer-amount (- amount fee))
  )
    (begin
      (asserts! (not (var-get contract-paused)) ERR_PAUSED)
      (try! (check-token-whitelisted token))
      (asserts! (>= allowance amount) ERR_INVALID_AMOUNT)
      (asserts! (>= owner-balance amount) ERR_INSUFFICIENT_BALANCE)
      (asserts! (is-valid-principal owner) ERR_INVALID_PARAMETER)
      (asserts! (is-valid-principal recipient) ERR_INVALID_PARAMETER)
      (asserts! (> amount u0) ERR_INVALID_AMOUNT)
      (map-set allowances {owner: owner, spender: tx-sender, token: (contract-of token)} (- allowance amount))
      (map-set balances {user: owner, token: (contract-of token)} (- owner-balance amount))
      (map-set balances {user: recipient, token: (contract-of token)} 
        (+ (default-to u0 (map-get? balances {user: recipient, token: (contract-of token)})) transfer-amount))
      (var-set accumulated-fees (+ (var-get accumulated-fees) fee))
      (emit-event "transfer-from" {event-data: (to-int amount)})
      (ok amount)
    )
  )
)

(define-public (batch-transfer (token <sip-010-trait>) (recipients (list 200 principal)) (amounts (list 200 uint)))
  (begin
    (asserts! (not (var-get contract-paused)) ERR_PAUSED)
    (try! (check-token-whitelisted token))
    (asserts! (is-eq (len recipients) (len amounts)) ERR_INVALID_PARAMETER)
    (asserts! (> (len recipients) u0) ERR_INVALID_PARAMETER)
    (asserts! (<= (len recipients) u50) ERR_INVALID_PARAMETER) ;; Limit batch size to 50
    (asserts! (check-principals recipients) ERR_INVALID_PARAMETER)
    (asserts! (check-amounts amounts) ERR_INVALID_PARAMETER)
    (ok (fold batch-transfer-fold 
      recipients
      {token: token, amounts: amounts, index: u0, success: true}
    ))
  )
)

(define-private (batch-transfer-fold 
  (recipient principal)
  (state {token: <sip-010-trait>, amounts: (list 200 uint), index: uint, success: bool}))
  (let (
    (token (get token state))
    (amounts (get amounts state))
    (current-index (get index state))
    (success (get success state))
  )
    (if (or (not success) (>= current-index (len amounts)))
      state
      (let (
        (amount (unwrap-panic (element-at amounts current-index)))
      )
        (match (transfer token recipient amount)
          transfer-success (merge state {index: (+ current-index u1), success: true})
          transfer-error (merge state {success: false})
        )
      )
    )
  )
)

(define-private (check-principals (principals (list 200 principal)))
  (fold check-principal-fold principals true)
)

(define-private (check-principal-fold (principal principal) (valid bool))
  (and valid (is-valid-principal principal))
)

(define-private (check-amounts (amounts (list 200 uint)))
  (fold check-amount-fold amounts true)
)

(define-private (check-amount-fold (amount uint) (valid bool))
  (and valid (> amount u0))
)

(define-public (withdraw-fees (token <sip-010-trait>))
  (begin
    (asserts! (is-contract-owner) ERR_UNAUTHORIZED)
    (try! (check-token-whitelisted token))
    (let ((fees (var-get accumulated-fees)))
      (asserts! (> fees u0) ERR_INSUFFICIENT_BALANCE)
      (let ((contract-balance (unwrap-panic (contract-call? token get-balance (as-contract tx-sender)))))
        (asserts! (>= contract-balance fees) ERR_INSUFFICIENT_BALANCE)
        (var-set accumulated-fees u0)
        (as-contract (try! (contract-call? token transfer tx-sender CONTRACT_OWNER fees)))
        (emit-event "fees-withdrawn" {event-data: (to-int fees)})
        (ok fees)
      )
    )
  )
)

(define-read-only (estimate-gas-cost (token <sip-010-trait>) (amount uint))
  (let (
    (gas-price (var-get current-gas-price))
    (fee (calculate-fee amount))
  )
    (ok {
      gas-estimate: (* amount gas-price),
      fee: fee,
      total-cost: (+ (* amount gas-price) fee)
    })
  )
)