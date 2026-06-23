structure Tests =
struct
  open Harness
  fun run () =
  let
    val () = section "Porter reference stems"
    val () = checkString "caresses->caress" ("caress", Stemmer.porter "caresses")
    val () = checkString "cat->cat" ("cat", Stemmer.porter "cat")
    val () = checkString "agreed->agree" ("agree", Stemmer.porter "agreed")
    val () = section "Snowball English"
    val () = checkString "identity round-trip" (Stemmer.porter "test", Stemmer.snowballEnglish "test")
  in Harness.run () end
end
