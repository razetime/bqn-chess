# Chess Library in bqn

# Utilities
Rm←¬∘∊/⊣
In←∊/⊣
Split←((⊢-˜+`×¬)∘=⊔⊢)
_ch←{(≥⟜('A'+32×𝕗)∧<⟜('Z'+32×𝕗))} # is piece on given side
I←/○⥊⟜(↕≢)
Lc←⊑+⟜(32×1="A["⊸⍋)
IB←{x‿y:(x<8)∧(y<8)∧(x≥0)∧y≥0} # In bounds
GB←{l←⟨⟩,𝕨⊸{l∾↩⋈𝕩,𝕨+𝕩}•_while_ IB 𝕩+𝕨,l} # gen bishop


# un←"♟♟♟♟♟♟♟♟♜♞♝♛♚♝♞♜♙♙♙♙♙♙♙♙♖♘♗♕♔♗♘♖"
# Basic game state
b←[
  "RNBQKBNR"
  "PPPPPPPP"
  "........"
  "........"
  "........"
  "........"
  "pppppppp"
  "rnbqkbnr"
]
mv←1 # White: 1

# Find unblocked moves for a piece. Does not look for checks.
UM←{
  𝕊 ⟨pc,r‿c,b,mv⟩:
  Blk←{⟨⟩:𝕩;l←𝕩⊑b,𝕩/˜∧`('.'=l)∨((¬mv)_ch l)} # Blocking
  {
     'p':
      f←mv⌽c∾˜¨(≥⟜0∧<⟜8)⊸/r+1‿2×¯1⋆mv # Calculate forward moves
      f↩f/˜∧`'.'=f⊑b    # remove blocked squares
      d←(r+¯1⋆mv)∾¨(<⟜8∧≥⟜0)¨⊸/c+1‿¯1 # add the captures
      f∾↩d/˜(¬mv)_ch d⊑b
      f Rm (¬mv) _ch b
    ;'r':
      cf←r∾¨1+c+↕7-c
      cb←⌽r∾¨↕c
      rf←c∾˜¨1+r+↕7-r
      rb←⌽c∾˜¨↕r
      ∾Blk¨ cf‿cb‿rf‿rb
    ;'b':
      ∾(Blk GB⟜r‿c)¨⟨1‿1,1‿¯1,¯1‿¯1,¯1‿1⟩
    ;'n':
      m←IB¨⊸/⟨1‿2,2‿1,1‿¯2,¯2,1,¯1‿2,2‿¯1,¯1‿¯2,¯2‿¯1⟩+<r‿c
      m/˜¬mv _ch m⊑b
    ;'k':
      m←IB¨⊸/⟨0‿1,1‿1,1‿0,1‿¯1,0‿¯1,¯1‿¯1,¯1‿0,¯1‿1⟩+<r‿c
      m/˜¬mv _ch m⊑b
    ;'q':
      ∾UM¨"rb"∾¨<⟨r‿c,b,mv⟩
    ; · :
      •Show "Invalid piece."‿𝕩
  } pc
}

# Find out if a side is in check.
IC←{
	𝕊 b‿mv:
	omv←¬mv
  cs←∾(UM·∾⟜b‿omv(Lc⊑⟜b)⊸⋈)¨I omv _ch b
  ks←I('K'+32×mv)=b
  ⊑ks∊cs
}

# Algebraic coordinates to numeric coordinates
VldA2N←{r‿c:((c≥'a')∧c≤'h')∧(r≥'1')∧r≤'8'} # Validity
A2N←-⟜"a1"

# Old function for formatting coordinates
# Fmt←{w‿wp‿b‿bp: (b-32)⌾(bp⊸⊑)w⌾(wp⊸⊑)8‿8⥊'.'}

# Long Algebraic Notation to move 
LT←A2N˘2‿2⊸⥊

Move←{
  r‿c‿r1‿c1‿p 𝕊 b: # p is the piece that goes at the end square.
                   # useful for promotion.
  '.'⌾(r‿c⊸⊑)p⌾(r1‿c1⊸⊑)b
}

CM←{ # Has the player lost
  𝕊 b‿mv:
  ps←⊑I b='K'+32×mv
  (IC b‿mv)∧⟨⟩≡UM ⟨'k',ps,b,mv⟩
}

# Actual game
{
  b‿mv:
  •Show b
  •Out "Enter Move"
  •Out (mv⊑"Black"‿"White")∾" to move"
  •Show I mv _ch b
	c‿r‿c1‿r1←(•GetLine@)-"a0a0"
	r‿r1 8⊸-↩
	p←r‿c⊑b
  {
    ⊑⟨r1‿c1⟩∊•Show UM⟨Lc p,r‿c,b,mv⟩ ?
      # Promotion
      ep ←{((r1=0)∧'p'=𝕩)∨((r1=7)∧'P'=𝕩) ? •Out "Enter promotion piece", ⊑•GetLine@ ; 𝕩}p
      # Now check and do the actual move.
      nb←r‿c‿r1‿c1‿p Move b
      {
        ¬IC nb‿mv ?
          ⟨nb,¬mv⟩
        ;
          •Show "Illegal move (move into check)."
          b‿mv
      }
    ; 
      •Show "Illegal move (blocked)."
      b‿mv
  }
} •_while_ (¬∘CM) b‿mv
