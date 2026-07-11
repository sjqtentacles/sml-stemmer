(* demo.sml - compare the Porter and Snowball-English stemmers across a
   handful of words spanning different suffix classes, then batch-stem the
   same list with stemAll. "dog's" shows the two algorithms diverge: Snowball
   English strips the possessive apostrophe (step 0) before stemming, Porter
   does not. Deterministic: pure string transforms only. *)

fun pad w s = if String.size s >= w then s
              else s ^ String.implode (List.tabulate (w - String.size s, fn _ => #" "))

val words = ["running", "flies", "happiness", "dog's", "caresses", "agreed"]

val () = print "Porter vs Snowball-English stemmer:\n\n"
val () = print ("  " ^ pad 12 "word" ^ pad 12 "porter" ^ "snowballEnglish\n")
val () =
  List.app
    (fn w =>
       print ("  " ^ pad 12 w ^ pad 12 (Stemmer.porter w) ^ Stemmer.snowballEnglish w ^ "\n"))
    words

val () = print "\nstemAll on the same word list:\n  ["
val () = print (String.concatWith ", " (Stemmer.stemAll words))
val () = print "]\n"
