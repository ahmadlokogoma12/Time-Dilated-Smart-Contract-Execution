;; Relativistic Time Tracking Contract

(define-map time-frames
  { id: uint }
  {
    reference-frame: (string-utf8 64),
    dilation-factor: uint,
    last-sync: uint
  }
)

(define-map time-conversions
  { source-frame: uint, target-frame: uint }
  { conversion-rate: uint }
)

(define-data-var next-frame-id uint u0)

(define-public (register-time-frame (reference-frame (string-utf8 64)) (dilation-factor uint))
  (let
    ((new-id (var-get next-frame-id)))
    (var-set next-frame-id (+ new-id u1))
    (ok (map-set time-frames
      { id: new-id }
      {
        reference-frame: reference-frame,
        dilation-factor: dilation-factor,
        last-sync: block-height
      }
    ))
  )
)

(define-public (set-conversion-rate (source-frame uint) (target-frame uint) (conversion-rate uint))
  (ok (map-set time-conversions
    { source-frame: source-frame, target-frame: target-frame }
    { conversion-rate: conversion-rate }
  ))
)

(define-read-only (get-time-frame (frame-id uint))
  (map-get? time-frames { id: frame-id })
)

(define-read-only (convert-time (time uint) (source-frame uint) (target-frame uint))
  (match (map-get? time-conversions { source-frame: source-frame, target-frame: target-frame })
    conversion (/ (* time (get conversion-rate conversion)) u1000000)
    time  ;; Default to no conversion if rate not found
  )
)

(define-read-only (get-current-time (frame-id uint))
  (match (map-get? time-frames { id: frame-id })
    frame
      (let
        ((elapsed (- block-height (get last-sync frame)))
         (dilated-time (* elapsed (get dilation-factor frame))))
        (/ dilated-time u1000000))
    block-height  ;; Default to block height if frame not found
  )
)

