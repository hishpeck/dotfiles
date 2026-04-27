; extends

; Match expressions
(match_conditional_expression
  conditional_expressions: (_) @assignment.lhs
  return_expression: (_) @assignment.rhs) @assignment.outer

(match_default_expression
  return_expression: (_) @assignment.rhs) @assignment.outer

(match_conditional_expression
  return_expression: (_) @assignment.inner)

(match_default_expression
  return_expression: (_) @assignment.inner)

; Standard assignments
(assignment_expression
  left: (_) @assignment.lhs
  right: (_) @assignment.rhs) @assignment.outer

(assignment_expression
  right: (_) @assignment.inner)

; Select the entire arrow function (e.g., `fn($x) => $x * 2`)
(arrow_function) @function.outer

; Select only the body/return expression of the arrow function (e.g., `$x * 2`)
(arrow_function
  body: (_) @function.inner)

; (Optional) Treat the arrow function body as a right-hand side assignment 
; so your `iv` or `av` keys work on it too!
(arrow_function
  body: (_) @assignment.rhs)
