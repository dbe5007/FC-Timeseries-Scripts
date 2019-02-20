# Organize timeseries for analyses in GIMME
# Daniel Elbich
# 4/22/17
#
# 
# Reads in text files containing timeseries data and
# merges into single CSV file for each subject. Includes
# error catch if different length of series is not equal
# for all regions.
#
# 

require(svDialogs)

returndir=getwd()

setwd(dlgDir(default = getwd())$res)

dir.create("output")

filelist=list.files(getwd(),'*.txt')

series = dlgInput("Enter Series Length", Sys.info()["series"])$res
series=gsub("[^0-9]", "", series)
series=as.double(series)

if (series==NA)
{
	cat("You're being bold....")
}


for (i in 1:length(filelist))
{
	data=read.table(filelist[i],header=TRUE)
	data=as.matrix(data)
	
	if (series~=length(data))
	{
		cat("Timeseries not correct. Check subject ",filelist[i])
		stop()
	}
	
	for (j in 1:dim(data)[2])
	{
		a=mean(data[,j])
		centered=data[,j]-a
		
		temp=nchar(filelist[i])-4
		
		name=paste("output/",substr(filelist[i],1,temp),"_",colnames(data)[j],".1D",sep="")
		
		write.table(centered,file=name,row.names=FALSE,col.names=FALSE)
		
	}
	
	
}

setwd(returndir)