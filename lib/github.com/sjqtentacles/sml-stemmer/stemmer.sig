(* stemmer.sig — Porter and Snowball English stemmers. *)

signature STEMMER =
sig
  (* Classic Porter (1980) stemmer, steps 1a through 5b. *)
  val porter : string -> string
  (* Snowball English (Porter2) variant; distinct from `porter`. *)
  val snowballEnglish : string -> string
  (* Alias for `porter`. *)
  val stem : string -> string
  (* Stem each word of a list. *)
  val stemAll : string list -> string list
end
