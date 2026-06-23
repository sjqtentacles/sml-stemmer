(* stemmer.sig — Porter and Snowball English stemmers. *)

signature STEMMER =
sig
  val porter : string -> string
  val snowballEnglish : string -> string
end
