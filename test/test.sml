structure Tests =
struct
  open Harness
  structure S = Stemmer
  fun run () =
  let
    val () = section "Porter reference stems"
    val () = checkString "caresses->caress" ("caress", S.porter "caresses")
    val () = checkString "ponies->poni" ("poni", S.porter "ponies")
    val () = checkString "ties->ti" ("ti", S.porter "ties")
    val () = checkString "caress->caress" ("caress", S.porter "caress")
    val () = checkString "cats->cat" ("cat", S.porter "cats")
    val () = checkString "cat->cat" ("cat", S.porter "cat")
    val () = checkString "feed->feed" ("feed", S.porter "feed")
    val () = checkString "agreed->agre" ("agre", S.porter "agreed")
    val () = checkString "plastered->plaster" ("plaster", S.porter "plastered")
    val () = checkString "motoring->motor" ("motor", S.porter "motoring")
    val () = checkString "happy->happi" ("happi", S.porter "happy")
    val () = checkString "relational->relat" ("relat", S.porter "relational")
    val () = checkString "vietnamization->vietnam" ("vietnam", S.porter "vietnamization")
    val () = checkString "rate->rate" ("rate", S.porter "rate")
    val () = checkString "controll->control" ("control", S.porter "controll")
    val () = checkString "roll->roll" ("roll", S.porter "roll")

    val () = section "Porter measure-gated steps"
    val () = checkString "conflated->conflat" ("conflat", S.porter "conflated")
    val () = checkString "troubled->troubl" ("troubl", S.porter "troubled")
    val () = checkString "running->run" ("run", S.porter "running")
    val () = checkString "hopping->hop" ("hop", S.porter "hopping")
    val () = checkString "falling->fall" ("fall", S.porter "falling")
    val () = checkString "happiness->happi" ("happi", S.porter "happiness")

    val () = section "stem alias and stemAll"
    val () = checkString "stem == porter" (S.porter "running", S.stem "running")
    val () = checkStringList "stemAll" (["cat","poni"], S.stemAll ["cats","ponies"])

    val () = section "Snowball English"
    val () = checkString "snowball identity on test" (S.porter "test", S.snowballEnglish "test")
    val () = checkString "snowball strips apostrophe-s" (S.porter "dog", S.snowballEnglish "dog's")
  in Harness.run () end
end
