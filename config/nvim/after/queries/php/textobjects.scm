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
