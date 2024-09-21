;; File name: sip-010-ft-trait.clar

(define-trait sip-010-ft-trait
  (
    ;; Transfer tokens to a specified principal
    (transfer (principal principal uint) (response bool uint))

    ;; Get the token's name
    (get-name () (response (string-ascii 32) uint))

    ;; Get the token's symbol
    (get-symbol () (response (string-ascii 32) uint))

    ;; Get the token's decimals
    (get-decimals () (response uint uint))

    ;; Get the token balance of a specified principal
    (get-balance (principal) (response uint uint))

    ;; Get the current total supply
    (get-total-supply () (response uint uint))

    ;; Optional: Mint new tokens
    (mint (uint principal) (response bool uint))

    ;; Optional: Burn tokens
    (burn (uint principal) (response bool uint))
  )
)