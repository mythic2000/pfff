(*s: pil.mli *)

(* The goal is to be significantly smaller than ast_php.mli *)

type name = Ast_php.name
type dname = Ast_php.dname

type qualifier = Ast_php.qualifier
type indirect = Ast_php.indirect
type binaryOp = Ast_php.binaryOp
type unaryOp = Ast_php.unaryOp
type constant = Ast_php.constant
type class_name_reference = Ast_php.class_name_reference
type assignOp = Ast_php.assignOp
type castOp = Ast_php.castOp

type type_info = {
  (* phptype is currently a list of types, to represent a union of types.
   * By default it is thus set to the empty list when we don't have
   * any type information.
   *)
  mutable t: Type_php.phptype;
}

type var = 
  | Var of dname
  | This of Ast_php.tok


(* Note the lack of a function calls case in lvalue. This is intented *)
type lvalue = lvaluebis * type_info
 and lvaluebis = 
   | VVar of var
   | VQualifier of qualifier * var

   | ArrayAccess of var * expr option
   | ObjAccess of var * name
   | DynamicObjAccess of var * var
   | IndirectAccess of var * indirect

(* Enforce only very basic expressions. Assign and function calls are in
 * the 'instruction' type below.
 *)
and expr = exprbis * type_info
 and exprbis =
  | Lv of lvalue
  | C of constant
  | ClassConstant of (qualifier * name)

  | Binary  of expr * binaryOp * expr
  | Unary   of unaryOp * expr
  | CondExpr of expr * expr * expr

  | ConsArray of expr list 
  | ConsHash  of (expr * expr) list 

  | Cast of castOp * expr
  | InstanceOf of expr * class_name_reference


type instr =
  | Assign of lvalue * assign_kind * expr
  | AssignRef of lvalue * lvalue
  (* Call(a,f,args) intuitively is an instruction a=f(args) *)
  | Call of lvalue * call_kind * argument list
  | Eval of expr

  and assign_kind = 
    | AssignEq
    | AssignOp of assignOp 

  and call_kind = 
    | SimpleCall        of name
    | StaticMethodCall  of qualifier * name
    | MethodCall        of var * name
    | DynamicCall       of qualifier option * var
    | DynamicMethodCall of var * var

    | New of class_name_reference 

   and argument = 
     | Arg of expr
     | ArgRef of lvalue

type stmt =
  | Instr of instr
  | Block of stmt list
  | EmptyStmt 
  | If of expr * stmt * stmt
  | While of expr * stmt
  | Break of expr option
  | Continue of expr option
  | Return of expr option
  | Throw of expr
  | Try of stmt * catch
  | Echo of expr list

 and catch = unit (* TODO *)

type toplevel = 
  | Require of require
  | TopStmt of stmt

  | FunctionDef of function_def
  | ClassDef of class_def
  | InterfaceDef of interface_def

 and function_def = unit (* TODO *)
 and class_def = unit (* TODO *)
 and interface_def = unit (* TODO *)
 and require = unit (* TODO *)

type program = toplevel list


(* for debugging *)
val string_of_instr: ?show_all:bool -> instr -> string
val string_of_stmt: ?show_all:bool -> stmt -> string
val string_of_expr: ?show_all:bool -> expr -> string

val string_of_program: ?show_all:bool -> program -> string

(* meta *)
val vof_expr: expr -> Ocaml.v
val vof_instr: instr -> Ocaml.v
val vof_argument: argument -> Ocaml.v

(*e: pil.mli *)
