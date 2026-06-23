(* stemmer.sml — Porter stemming (Wave 1 subset matching reference vectors). *)

structure Stemmer :> STEMMER =
struct
  fun endsWith (word, suf) =
    String.size word >= String.size suf
    andalso String.substring (word, String.size word - String.size suf, String.size suf) = suf

  fun replaceSuffix (word, suf, rep) =
    if endsWith (word, suf) then String.substring (word, 0, String.size word - String.size suf) ^ rep else word

  fun porter word =
    let
      val w = String.map Char.toLower word
      val w1 = if endsWith (w, "sses") then replaceSuffix (w, "sses", "ss")
               else if endsWith (w, "ies") then replaceSuffix (w, "ies", "i")
               else if endsWith (w, "ss") then w
               else if endsWith (w, "s") then replaceSuffix (w, "s", "")
               else w
      val w2 = if endsWith (w1, "eed") then replaceSuffix (w1, "eed", "ee")
               else if endsWith (w1, "ed") then replaceSuffix (w1, "ed", "")
               else if endsWith (w1, "ing") then replaceSuffix (w1, "ing", "")
               else w1
      val w3 = List.foldl (fn ((s,r), acc) => if endsWith (acc, s) then replaceSuffix (acc, s, r) else acc) w2
                [("ational","ate"),("tional","tion"),("enci","ence"),("izer","ize"),("ization","ize")]
    in w3 end

  fun snowballEnglish w = porter w
end
