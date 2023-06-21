open Expression
open Types

let mk_val (i : int) : expr = Val (Int i)
let mk_neg (e : expr) : expr = Unop (Int I.Neg, e)
let mk_add (e1 : expr) (e2 : expr) : expr = Binop (Int I.Add, e1, e2)
let mk_sub (e1 : expr) (e2 : expr) : expr = Binop (Int I.Sub, e1, e2)
let mk_mul (e1 : expr) (e2 : expr) : expr = Binop (Int I.Mul, e1, e2)
let mk_div (e1 : expr) (e2 : expr) : expr = Binop (Int I.Div, e1, e2)
let mk_rem (e1 : expr) (e2 : expr) : expr = Binop (Int I.Rem, e1, e2)
let mk_shl (e1 : expr) (e2 : expr) : expr = Binop (Int I.Shl, e1, e2)
let mk_shr_a (e1 : expr) (e2 : expr) : expr = Binop (Int I.ShrA, e1, e2)
let mk_shr_l (e1 : expr) (e2 : expr) : expr = Binop (Int I.ShrL, e1, e2)
let mk_and (e1 : expr) (e2 : expr) : expr = Binop (Int I.And, e1, e2)
let mk_or (e1 : expr) (e2 : expr) : expr = Binop (Int I.Or, e1, e2)
let mk_xor (e1 : expr) (e2 : expr) : expr = Binop (Int I.Xor, e1, e2)
let mk_pow (e1 : expr) (e2 : expr) : expr = Binop (Int I.Pow, e1, e2)
let mk_eq (e1 : expr) (e2 : expr) : expr = Relop (Int I.Eq, e1, e2)
let mk_ne (e1 : expr) (e2 : expr) : expr = Relop (Int I.Ne, e1, e2)
let mk_lt (e1 : expr) (e2 : expr) : expr = Relop (Int I.Lt, e1, e2)
let mk_le (e1 : expr) (e2 : expr) : expr = Relop (Int I.Le, e1, e2)
let mk_gt (e1 : expr) (e2 : expr) : expr = Relop (Int I.Gt, e1, e2)
let mk_ge (e1 : expr) (e2 : expr) : expr = Relop (Int I.Ge, e1, e2)
let mk_to_string (e : expr) : expr = Cvtop (Int I.ToString, e)
let mk_of_string (e : expr) : expr = Cvtop (Int I.OfString, e)
let mk_of_real (e : expr) : expr = Cvtop (Int I.ReinterpretReal, e)