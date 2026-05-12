import sys
import os
import pandas as pd

inputfile = sys.argv[1]  # pass filename when running: python script.py your_file.psl
basename = os.path.splitext(os.path.basename(inputfile))[0] #os.path.basename strips the directory path and os.path.splittext strips off the extension
outputfile = f"{basename}_true_inversions.tsv"

# Load PSL (no header)
cols = ["matches","misMatches","repMatches","nCount","qNumInsert","qBaseInsert",
        "tNumInsert","tBaseInsert","strand","qName","qSize","qStart","qEnd",
        "tName","tSize","tStart","tEnd","blockCount","blockSizes","qStarts","tStarts"]

psl = pd.read_csv(inputfile, sep="\t", names=cols, comment="#")

##Quality filters
psl["identity"] = psl["matches"] / (psl["matches"] + psl["misMatches"] + psl["tBaseInsert"])
psl["tLen"] = psl["tEnd"] - psl["tStart"]

#plus  = psl[(psl["strand"] == "++") & (psl["identity"] >= 0.85) & (psl["tLen"] >= 10000)]
#minus = psl[(psl["strand"] == "+-") & (psl["identity"] >= 0.85) & (psl["tLen"] >= 10000)]

plus  = psl[(psl["strand"] == "++") & (psl["tLen"] >= 1000)]
minus = psl[(psl["strand"] == "+-") & (psl["tLen"] >= 1000)]

#Different length thresholds for plus blocks can be explored (eg., 10000, 50000, 100000)

#print(len(plus))
#print(len(minus))

##syntenic context

# Keep only minus blocks whose qName+tName combination exists in plus. To make sure that they exist on same 
valid_pairs = plus[["qName", "tName"]].drop_duplicates()
minus = minus.merge(valid_pairs, on=["qName", "tName"]) #this works like sequel inner join

print(f"Valid chromosome pairs: {len(valid_pairs)}")
print(f"Minus blocks after chrom pair filter: {len(minus)}")

#loop over each candidate inversion and check for flanking anchors 
confirmed_inversions = []

FLANK = 500_000  # look within 500 kb for flanking anchors. This is just python's way of writing 5000000 bp or 500 kb in a readable way
FLANK = 200_000
#for closely related species, use smaller flank window
#The more diverged species, more genome has been reshuffled. So you need a larger flank window

#Here _ is used in completely unrelated way as compared to above.
#It is basically a throaway variable that we don't need. Equivalent to saying for index, inv in minus.iterrows()
for _, inv in minus.iterrows():
    # Find plus-strand blocks on the same query and target chrom pair, flanking this inversion
    same_pair = plus[(plus["tName"] == inv["tName"]) & (plus["qName"] == inv["qName"])]
    left_anchor  = same_pair[same_pair["tEnd"]   <= inv["tStart"] + FLANK]
    right_anchor = same_pair[same_pair["tStart"] >= inv["tEnd"]   - FLANK]
    
    if len(left_anchor) > 0 and len(right_anchor) > 0:
        confirmed_inversions.append(inv)

inv_df = pd.DataFrame(confirmed_inversions)
inv_df["inv_length"] = inv_df["tEnd"] - inv_df["tStart"]
total_length = inv_df["inv_length"].sum()

print(f"Confirmed inversions: {len(inv_df)}")
print(f"Total inversion length: {total_length:,} bp ({total_length/1e6:.2f} Mb)")
inv_df.to_csv(outputfile, sep="\t", index=False)
print(f"Output written to: {outputfile}")
