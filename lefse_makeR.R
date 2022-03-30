
# ////// 1 Metadata map
#load map file, get classes names
mm=read.delim2(file = "3-metamap.txt", check.names = F)


# ////// 2 Create header
#read 1st otutable row as a header, get samples
oth=read.delim2(file = "2-input-table.txt", check.names = F, header = F, nrows = 1, skip = 1)

#replace "#OTU ID" with "samples"
oth[1,1]="Samples"

#remove last column (usually the column name "taxonomy" or "consensus lineage")
oth=oth[,-ncol(oth)]

#create empty line above 
oth=rbind(NA, oth)

oth[1,]=transpose(mm[match(x=oth[2,], table = mm$name),])[2,]

oth[1,1]="Class"


# ////// 3 Transform body
#read otutable, skip 1st line, get body
otb=read.delim2(file = "2-input-table.txt", check.names = F, header = F, skip = 2)

#copy taxonomy  (last column) to 1st column 
otb[,1]=otb[ , ncol(otb)]

#remove last column (the copied taxonomy)
otb=otb[,-ncol(otb)]

#Replace "; " with "|"
otb=data.frame(lapply(otb, function(x) {
  gsub("; ", "|", x)
  }))


# ////// 4 Merge header and body
#merge parts
final=rbind(oth,otb)

#write output file
write.table(x = final, file = "lefse-input.tabular", sep = "\t", col.names = F, row.names = F)


