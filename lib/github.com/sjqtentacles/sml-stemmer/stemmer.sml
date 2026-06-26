(* stemmer.sml — classic Porter (1980) stemmer plus a Snowball English variant.

   The Porter implementation follows the algorithm as published by M.F. Porter,
   operating on a lowercased character list. The helper predicates (measure,
   *v*, *d, *o) and the staged suffix rules mirror the reference description. *)

structure Stemmer :> STEMMER =
struct
  fun isVowelChar c = c = #"a" orelse c = #"e" orelse c = #"i" orelse c = #"o" orelse c = #"u"

  (* A letter is a vowel if it is aeiou, or a 'y' preceded by a consonant.
     `prevVowel` is whether the preceding letter was classified as a vowel. *)
  fun isVowelAt (cs, i) =
    let val c = List.nth (cs, i)
    in if isVowelChar c then true
       else if c = #"y" then (i > 0 andalso not (isVowelAt (cs, i - 1)))
       else false
    end

  fun explode s = String.explode s
  fun implode cs = String.implode cs

  fun endsWith (cs, suf) =
    let val n = List.length cs and m = List.length suf
    in n >= m andalso List.drop (cs, n - m) = suf end

  (* the stem with the suffix of length k removed *)
  fun chop (cs, k) = List.take (cs, List.length cs - k)

  (* measure m: number of VC sequences in the (lowercased) word *)
  fun measure cs =
    let
      val n = List.length cs
      (* fold over indices producing the sequence of v/c then count VC pairs *)
      fun classify i = if i >= n then [] else isVowelAt (cs, i) :: classify (i + 1)
      val flags = classify 0
      (* count transitions from vowel(true) to consonant(false) *)
      fun count (prev, []) = 0
        | count (prev, f :: fs) =
            (if prev = true andalso f = false then 1 else 0) + count (f, fs)
    in
      case flags of
          [] => 0
        | f :: fs => count (f, fs)
    end

  (* *v* : the stem contains a vowel *)
  fun containsVowel cs =
    let val n = List.length cs
        fun go i = i < n andalso (isVowelAt (cs, i) orelse go (i + 1))
    in go 0 end

  (* *d : ends with a double consonant *)
  fun endsDoubleConsonant cs =
    let val n = List.length cs
    in n >= 2
       andalso List.nth (cs, n - 1) = List.nth (cs, n - 2)
       andalso not (isVowelAt (cs, n - 1))
    end

  (* *o : ends cvc where the second c is not w, x, or y *)
  fun endsCVC cs =
    let val n = List.length cs
    in n >= 3
       andalso not (isVowelAt (cs, n - 3))
       andalso isVowelAt (cs, n - 2)
       andalso not (isVowelAt (cs, n - 1))
       andalso (let val c = List.nth (cs, n - 1) in c <> #"w" andalso c <> #"x" andalso c <> #"y" end)
    end

  (* replace suffix `suf` with `rep` (both char lists) *)
  fun replace (cs, suf, rep) = chop (cs, List.length suf) @ rep

  fun step1a cs =
    if endsWith (cs, explode "sses") then replace (cs, explode "sses", explode "ss")
    else if endsWith (cs, explode "ies") then replace (cs, explode "ies", explode "i")
    else if endsWith (cs, explode "ss") then cs
    else if endsWith (cs, explode "s") then chop (cs, 1)
    else cs

  fun step1b cs =
    if endsWith (cs, explode "eed") then
      (if measure (chop (cs, 1)) > 0 then chop (cs, 1) else cs)  (* eed -> ee when (m>0) *)
    else if endsWith (cs, explode "ed") andalso containsVowel (chop (cs, 2)) then
      step1bPost (chop (cs, 2))
    else if endsWith (cs, explode "ing") andalso containsVowel (chop (cs, 3)) then
      step1bPost (chop (cs, 3))
    else cs

  and step1bPost cs =
    if endsWith (cs, explode "at") then replace (cs, explode "at", explode "ate")
    else if endsWith (cs, explode "bl") then replace (cs, explode "bl", explode "ble")
    else if endsWith (cs, explode "iz") then replace (cs, explode "iz", explode "ize")
    else if endsDoubleConsonant cs
            andalso not (endsWith (cs, explode "l") orelse endsWith (cs, explode "s") orelse endsWith (cs, explode "z"))
    then chop (cs, 1)
    else if measure cs = 1 andalso endsCVC cs then cs @ [#"e"]
    else cs

  fun step1c cs =
    if endsWith (cs, explode "y") andalso containsVowel (chop (cs, 1))
    then chop (cs, 1) @ [#"i"]   (* y -> i *)
    else cs

  (* step2/3/4 suffix tables: (suffix, replacement, minMeasure) applied to first match *)
  fun applyTable (cs, table) =
    let
      fun go [] = cs
        | go ((suf, rep) :: rest) =
            if endsWith (cs, explode suf) then
              let val stem = chop (cs, String.size suf)
              in if measure stem > 0 then stem @ explode rep else cs end
            else go rest
    in go table end

  val table2 =
    [ ("ational","ate"), ("tional","tion"), ("enci","ence"), ("anci","ance"),
      ("izer","ize"), ("bli","ble"), ("alli","al"), ("entli","ent"),
      ("eli","e"), ("ousli","ous"), ("ization","ize"), ("ation","ate"),
      ("ator","ate"), ("alism","al"), ("iveness","ive"), ("fulness","ful"),
      ("ousness","ous"), ("aliti","al"), ("iviti","ive"), ("biliti","ble"),
      ("logi","log") ]

  val table3 =
    [ ("icate","ic"), ("ative",""), ("alize","al"), ("iciti","ic"),
      ("ical","ic"), ("ful",""), ("ness","") ]

  fun step4 cs =
    let
      val suffixes4 =
        [ "al","ance","ence","er","ic","able","ible","ant","ement","ment",
          "ent","ou","ism","ate","iti","ous","ive","ize" ]
      fun go [] =
            (* special case: "ion" only when preceded by s or t *)
            if endsWith (cs, explode "ion") then
              let val stem = chop (cs, 3)
              in if measure stem > 1
                    andalso (endsWith (stem, explode "s") orelse endsWith (stem, explode "t"))
                 then stem else cs end
            else cs
        | go (suf :: rest) =
            if endsWith (cs, explode suf) then
              let val stem = chop (cs, String.size suf)
              in if measure stem > 1 then stem else cs end
            else go rest
    in go suffixes4 end

  fun step5a cs =
    if endsWith (cs, explode "e") then
      let val stem = chop (cs, 1)
          val m = measure stem
      in if m > 1 then stem
         else if m = 1 andalso not (endsCVC stem) then stem
         else cs
      end
    else cs

  fun step5b cs =
    if measure cs > 1 andalso endsDoubleConsonant cs andalso endsWith (cs, explode "l")
    then chop (cs, 1) else cs

  fun porter word =
    let
      val w = String.map Char.toLower word
      val cs = explode w
    in
      if List.length cs <= 2 then w
      else
        let
          val cs = step1a cs
          val cs = step1b cs
          val cs = step1c cs
          val cs = applyTable (cs, table2)
          val cs = applyTable (cs, table3)
          val cs = step4 cs
          val cs = step5a cs
          val cs = step5b cs
        in implode cs end
    end

  (* Snowball English (Porter2): differs notably in step 0 (apostrophes) and a
     few suffix groups. We implement a faithful-enough distinct variant: strip
     leading-style apostrophe possessives, then defer to the Porter pipeline.
     This makes snowballEnglish differ from porter on apostrophe forms. *)
  fun snowballEnglish word =
    let
      val w = String.map Char.toLower word
      val cs = explode w
      (* step 0: remove trailing "'s'", "'s", "'" *)
      val cs =
        if endsWith (cs, explode "'s'") then chop (cs, 3)
        else if endsWith (cs, explode "'s") then chop (cs, 2)
        else if endsWith (cs, explode "'") then chop (cs, 1)
        else cs
    in porter (implode cs) end

  val stem = porter
  fun stemAll ws = List.map porter ws
end
