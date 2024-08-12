open Types
open Fmt
open Syntax

(*

unop ::= '-'                       ==> Neg

binop ::= '+'                      ==> Plus
  | '-'                            ==> Minus
  | '*'                            ==> Mult
  | '/'                            ==> Div

term ::= '(' pterm ')'             ==> pterm
  | result                         ==> Result

pterm ::= 'i32' i32                ==> Int32 (Int32.of_string i32)
  | 'var' ind                      ==> Var (Text ind)                     if (valid_text_indice ind)
  | 'global' ind                   ==> Global (Text ind)                  if (valid_text_indice ind)
                                   ==> Global (Raw ind)                   if (valid_binary_indice ind)
  | 'binder' ind                   ==> Binder (Text ind)                  if (valid_text_indice ind)
                                   ==> Binder (Raw ind)                   if (valid_binary_indice ind)
  | unop term_1                    ==> Unop (unop, term_1)
  | binop term_1 term_2            ==> BinOp (binop, term_1, term_2)

binpred ::= '>='                   ==> Ge
  | '>'                            ==> Gt
  | '<='                           ==> Le
  | '<'                            ==> Lt
  | '='                            ==> Eq
  | '!='                           ==> Neq

unconnect ::= '!'                  ==> Not

binconnect ::= '&&'                ==> And
  | '||'                           ==> Or
  | '==>'                          ==> Imply
  | '<==>'                         ==> Equiv

prop ::= '(' pprop ')'             ==> pprop
  | 'true'                         ==> Const true
  | 'false'                        ==> Const false

binder ::= 'forall'                ==> Forall
  | 'exists'                       ==> Exists

binder_type ::= 'i32'              ==> I32
  | 'i64'                          ==> I64
  | 'f32'                          ==> F32
  | 'f64'                          ==> F64

pprop ::= binpred term_1 term_2    ==> BinPred (binpred, term_1, term_2)
  | unconnect prop_1               ==> UnConnect (unconnect, prop_1)
  | binconnect prop_1 prop_2       ==> BinConnect (binconnect, prop_1, prop_2)
  | binder binder_type prop_1      ==> Binder (binder, binder_type, None, prop_1)
  | binder binder_type ind prop_1  ==> Binder (binder, binder_type, Some ind, prop_1)
                                                                          if (valid_text_indice ind)
*)

type nonrec binpred =
  | Ge
  | Gt
  | Le
  | Lt
  | Eq
  | Neq

type nonrec unconnect = Not

type nonrec binconnect =
  | And
  | Or
  | Imply
  | Equiv

type nonrec binder =
  | Forall
  | Exists

type nonrec binder_type = num_type

type nonrec unop = Neg

type nonrec binop =
  | Plus
  | Minus
  | Mult
  | Div

type 'a term =
  | Int32 : int32 -> 'a term
  | Var : text indice -> text term
  | GlobalVar : 'a indice -> 'a term
  | BinderVar : 'a indice -> 'a term
  | UnOp : unop * 'a term -> 'a term
  | BinOp : binop * 'a term * 'a term -> 'a term
  | Result : 'a term

type 'a prop =
  | Const : bool -> 'a prop
  | BinPred : binpred * 'a term * 'a term -> 'a prop
  | UnConnect : unconnect * 'a prop -> 'a prop
  | BinConnect : binconnect * 'a prop * 'a prop -> 'a prop
  | Binder : binder * binder_type * string option * 'a prop -> 'a prop

let pp_bool fmt = function true -> pf fmt "true" | false -> pf fmt "false"

let pp_binpred fmt = function
  | Ge -> pf fmt ">="
  | Gt -> pf fmt ">"
  | Le -> pf fmt "<="
  | Lt -> pf fmt "<"
  | Eq -> pf fmt "="
  | Neq -> pf fmt "!="

let pp_unconnect fmt = function Not -> pf fmt "!"

let pp_binconnect fmt = function
  | And -> pf fmt "&&"
  | Or -> pf fmt "||"
  | Imply -> pf fmt "==>"
  | Equiv -> pf fmt "<==>"

let pp_binder fmt = function
  | Forall -> pf fmt "forall"
  | Exists -> pf fmt "exists"

let pp_binder_type = pp_num_type

let pp_unop fmt = function Neg -> pf fmt "-"

let pp_binop fmt = function
  | Plus -> pf fmt "+"
  | Minus -> pf fmt "-"
  | Mult -> pf fmt "*"
  | Div -> pf fmt "/"

let rec pp_term : type a. formatter -> a term -> unit =
 fun fmt -> function
  | Int32 i -> pf fmt "%i" (Int32.to_int i)
  | Var ind -> pf fmt "%a" pp_indice ind
  | GlobalVar ind -> pf fmt "global.%a" pp_indice ind
  | BinderVar ind -> pf fmt "binder.%a" pp_indice ind
  | UnOp (u, tm1) -> pf fmt "@[<hv 2>%a@ %a@]" pp_unop u pp_term tm1
  | BinOp (b, tm1, tm2) ->
    pf fmt "@[<hv 2>%a@ %a@ %a@]" pp_binop b pp_term tm1 pp_term tm2
  | Result -> pf fmt {|\result|}

let rec pp_prop : type a. formatter -> a prop -> unit =
 fun fmt -> function
  | Const bool -> pf fmt "%a" pp_bool bool
  | BinPred (b, tm1, tm2) ->
    pf fmt "@[<hv 2>%a@ %a@ %a@]" pp_term tm1 pp_binpred b pp_term tm2
  | UnConnect (u, pr1) -> pf fmt "@[<hv 2>%a@ %a@]" pp_unconnect u pp_prop pr1
  | BinConnect (b, pr1, pr2) ->
    pf fmt "@[<hv 2>%a@ %a@ %a@]" pp_prop pr1 pp_binconnect b pp_prop pr2
  | Binder (b, bt, id_opt, pr1) -> (
    match id_opt with
    | Some id ->
      pf fmt "@[<hv 2>%a@ %a@ %a, %a@]" pp_binder b pp_binder_type bt pp_id id
        pp_prop pr1
    | None ->
      pf fmt "@[<hv 2>%a@ %a@, %a@]" pp_binder b pp_binder_type bt pp_prop pr1 )

let valid_text_indice_char = function
  | '0' .. '9'
  | 'a' .. 'z'
  | 'A' .. 'Z'
  | '!' | '#' | '$' | '%' | '&' | '\'' | '*' | '+' | '-' | '.' | '/' | ':' | '<'
  | '=' | '>' | '?' | '@' | '\\' | '^' | '_' | '`' | '|' | '~' ->
    true
  | _ -> false

let valid_text_indice ind =
  match List.of_seq (String.to_seq ind) with
  | '$' :: rest -> List.for_all valid_text_indice_char rest
  | _ -> false

let valid_binary_indice x =
  Option.to_result ~none:(`Invalid_indice x) (int_of_string x)

let parse_indice ind =
  if valid_text_indice ind then ok @@ Text ind
  else
    let* ind = valid_binary_indice ind in
    ok @@ Raw ind

let parse_binder_type =
  let open Sexp in
  function
  | Atom "i32" -> ok I32
  | Atom "i64" -> ok I64
  | Atom "f32" -> ok F32
  | Atom "f64" -> ok F64
  | _ as bt -> Error (`Unknown_binder_type bt)

let rec parse_term =
  let open Sexp in
  function
  (* Int32 *)
  | List [ Atom "i32"; Atom i32 ] -> ok @@ Int32 (Int32.of_string i32)
  (* Var *)
  | List [ Atom "local"; Atom ind ] ->
    if valid_text_indice ind then ok @@ Var (Text ind)
    else Error (`Invalid_text_indice ind)
  (* GlobalVar *)
  | List [ Atom "global"; Atom ind ] ->
    let+ ind = parse_indice ind in
    GlobalVar ind
  (* BinderVar *)
  | List [ Atom "binder"; Atom ind ] ->
    let+ ind = parse_indice ind in
    BinderVar ind
  (* UnOp *)
  | List [ Atom "-"; tm1 ] ->
    let+ tm1 = parse_term tm1 in
    UnOp (Neg, tm1)
  (* BinOp *)
  | List [ Atom "+"; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinOp (Plus, tm1, tm2)
  | List [ Atom "-"; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinOp (Minus, tm1, tm2)
  | List [ Atom "*"; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinOp (Mult, tm1, tm2)
  | List [ Atom "/"; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinOp (Div, tm1, tm2)
  (* Result *)
  | Atom "result" -> ok Result
  (* Invalid *)
  | _ as tm -> Error (`Unknown_term tm)

let rec parse_prop =
  let open Sexp in
  function
  (* Const *)
  | Atom "true" -> ok @@ Const true
  | Atom "false" -> ok @@ Const false
  (* BinPred *)
  | List [ Atom ">="; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinPred (Ge, tm1, tm2)
  | List [ Atom ">"; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinPred (Gt, tm1, tm2)
  | List [ Atom "<="; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinPred (Le, tm1, tm2)
  | List [ Atom "<"; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinPred (Lt, tm1, tm2)
  | List [ Atom "="; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinPred (Eq, tm1, tm2)
  | List [ Atom "!="; tm1; tm2 ] ->
    let* tm1 = parse_term tm1 in
    let+ tm2 = parse_term tm2 in
    BinPred (Neq, tm1, tm2)
  (* UnConnect *)
  | List [ Atom "!"; pr1 ] ->
    let+ pr1 = parse_prop pr1 in
    UnConnect (Not, pr1)
  (* BinConnect *)
  | List [ Atom "&&"; pr1; pr2 ] ->
    let* pr1 = parse_prop pr1 in
    let+ pr2 = parse_prop pr2 in
    BinConnect (And, pr1, pr2)
  | List [ Atom "||"; pr1; pr2 ] ->
    let* pr1 = parse_prop pr1 in
    let+ pr2 = parse_prop pr2 in
    BinConnect (Or, pr1, pr2)
  | List [ Atom "==>"; pr1; pr2 ] ->
    let* pr1 = parse_prop pr1 in
    let+ pr2 = parse_prop pr2 in
    BinConnect (Imply, pr1, pr2)
  | List [ Atom "<==>"; pr1; pr2 ] ->
    let* pr1 = parse_prop pr1 in
    let+ pr2 = parse_prop pr2 in
    BinConnect (Equiv, pr1, pr2)
  (* Binder *)
  | List [ Atom "forall"; bt; pr1 ] ->
    let* bt = parse_binder_type bt in
    let+ pr1 = parse_prop pr1 in
    Binder (Forall, bt, None, pr1)
  | List [ Atom "forall"; bt; Atom ind; pr1 ] ->
    if valid_text_indice ind then
      let* bt = parse_binder_type bt in
      let+ pr1 = parse_prop pr1 in
      Binder (Forall, bt, Some ind, pr1)
    else Error (`Invalid_text_indice ind)
  | List [ Atom "exists"; bt; pr1 ] ->
    let* bt = parse_binder_type bt in
    let+ pr1 = parse_prop pr1 in
    Binder (Exists, bt, None, pr1)
  | List [ Atom "exists"; bt; Atom ind; pr1 ] ->
    if valid_text_indice ind then
      let* bt = parse_binder_type bt in
      let+ pr1 = parse_prop pr1 in
      Binder (Exists, bt, Some ind, pr1)
    else Error (`Invalid_text_indice ind)
  (* invalid *)
  | _ as pr -> Error (`Unknown_prop pr)