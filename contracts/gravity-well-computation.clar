;; Gravity-well Computation Optimization Contract

(define-map gravity-wells
  { id: uint }
  {
    location: (string-utf8 64),
    strength: uint,
    efficiency-factor: uint
  }
)

(define-map computation-tasks
  { id: uint }
  {
    gravity-well-id: uint,
    complexity: uint,
    status: (string-ascii 20),
    result-hash: (optional (string-utf8 64))
  }
)

(define-data-var next-well-id uint u0)
(define-data-var next-task-id uint u0)

(define-public (register-gravity-well (location (string-utf8 64)) (strength uint) (efficiency-factor uint))
  (let
    ((new-id (var-get next-well-id)))
    (var-set next-well-id (+ new-id u1))
    (ok (map-set gravity-wells
      { id: new-id }
      {
        location: location,
        strength: strength,
        efficiency-factor: efficiency-factor
      }
    ))
  )
)

(define-public (submit-computation-task (gravity-well-id uint) (complexity uint))
  (let
    ((new-id (var-get next-task-id)))
    (var-set next-task-id (+ new-id u1))
    (ok (map-set computation-tasks
      { id: new-id }
      {
        gravity-well-id: gravity-well-id,
        complexity: complexity,
        status: "pending",
        result-hash: none
      }
    ))
  )
)

(define-public (complete-computation (task-id uint) (result-hash (string-utf8 64)))
  (match (map-get? computation-tasks { id: task-id })
    task
      (ok (map-set computation-tasks
        { id: task-id }
        (merge task {
          status: "completed",
          result-hash: (some result-hash)
        })
      ))
    (err u404)
  )
)

(define-read-only (get-gravity-well (well-id uint))
  (map-get? gravity-wells { id: well-id })
)

(define-read-only (get-computation-task (task-id uint))
  (map-get? computation-tasks { id: task-id })
)

(define-read-only (calculate-computation-time (gravity-well-id uint) (complexity uint))
  (match (map-get? gravity-wells { id: gravity-well-id })
    well
      (let
        ((base-time complexity)
         (efficiency (get efficiency-factor well))
         (strength (get strength well)))
        (/ (* base-time u1000000) (* efficiency strength)))
    complexity  ;; Default to complexity if well not found
  )
)

