#!/usr/local/bin/Rscript

options(stringsAsFactors = FALSE);

library(IRanges)

qw <- function(...) {
  as.character(sys.call()[-1])
}

##for testing
#args <- commandArgs(trailingOnly=TRUE)
#filename = args[1]
filename = "results/alignment/bowtie/peakfinding/newannotation/peaks.RangedData.RData"

rd <- get(load(filename))

library(ChIPpeakAnno)
library(biomaRt)
ensmart <- useMart("ensembl", dataset="mmusculus_gene_ensembl")

#remove "chr" prefix for  ChIPpeakAnno
names(rd)<-gsub("chr","",names(rd))

#change "M" to "MT" for ChIPpeakAnno
id<-which(names(rd)=="M")
if (length(id)>0){
   names(rd)[id]<-"MT"
}


# NOTE: TSS.mouse.NCBIM37 is actually *gene* start and end positions, not individual transcripts.

#get the most recent annotation data from ensembl
tss <- getAnnotation(ensmart, "TSS")
save(tss, file=paste(dirname(filename),"/tss.RData",sep=""))

###########split everything into pos/neg strand and stick back together after...

#split tss
tss.df <- as.data.frame(tss)
tss.pos <- tss.df[which(tss.df[,"strand"]==1),]
tss.neg <- tss.df[which(tss.df[,"strand"]==-1),]
tss.pos <- RangedData(tss.pos)
tss.neg <- RangedData(tss.neg)

###find nearest on positive strand first
nearest.tss.start.pos <- annotatePeakInBatch(rd,
                                         AnnotationData=tss.pos,
                                         PeakLocForDistance = "middle",    # from the middle of the peak
                                         FeatureLocForDistance = "start",  # to the start of the feature
                                         output = "both",
                                         multiple=TRUE
                                         )

# the overlapping stuff would be exactly the same,so just get nearest 
nearest.tss.end.pos <- annotatePeakInBatch(rd,
                                       AnnotationData=tss.pos,
                                       PeakLocForDistance = "middle",    # from the middle of the peak
                                       FeatureLocForDistance = "end",    # to the end of the feature
                                       output = "nearestStart"
                                       )
###then find stuff on negative strand
nearest.tss.start.neg <- annotatePeakInBatch(rd,
                                         AnnotationData=tss.neg,
                                         PeakLocForDistance = "middle",    # from the middle of the peak
                                         FeatureLocForDistance = "start",  # to the start of the feature
                                         output = "both",
                                         multiple=TRUE
                                         )

# the overlapping stuff would be exactly the same,so just get nearest 
nearest.tss.end.neg <- annotatePeakInBatch(rd,
                                       AnnotationData=tss.neg,
                                       PeakLocForDistance = "middle",    # from the middle of the peak
                                       FeatureLocForDistance = "end",    # to the end of the feature
                                       output = "nearestStart"
                                       )

