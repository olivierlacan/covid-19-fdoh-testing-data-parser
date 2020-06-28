# library(XML);library(pdftools);library(stringr)
 
# url <- ('http://ww11.doh.state.fl.us/comm/_partners/action/report_archive/state/state_reports_latest.pdf')
# text1=pdf_text(url)

require 'rubygems'
require 'bundler'

Bundler.require(:development)

require "net/http"
require "json"
require "csv"
require "date"

binding.irb

latest_report_uri = URI "http://ww11.doh.state.fl.us/comm/_partners/action/report_archive/state/state_reports_latest.pdf"
latest_report = Net::HTTP.get(latest_report_uri)

match, year, month, day, hour, minute, seconds = *latest_report[/CreationDate(\(D:\d+)/].split(":").last.match(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/)

filename = "state_report_#{year}-#{month}-#{day}_#{hour}:#{minute}:#{seconds}.pdf"

File.open(filename, "wb") do |file|
  file << latest_report
end

pdf = Origami::PDF.read filename, lazy: TRUE
  binding.irb
pdf

# case_x=grepl("line list of cases",text1)
# case_tables=which(case_x==TRUE)
# mm=length(case_tables)


 
# case_data=NULL
# for(i in 1:mm){
 
#     ttt <- t(str_split(text1[which(case_x==TRUE)[i]], "\r\n", simplify = TRUE))[-(1:6),]
 
#     t2=strsplit(ttt[[1]],"")[[1]]
#     #hh=str_replace(t2," ","|")
#     t_a=c(regexpr("[[:alpha:]]", t2))
 
#     county_start=which(t_a==1)[1]
#     lx=length(t2)
#     cwidths=c(county_start-1,13,5,8,9,15,13,8)
#     sxx=c(1,cumsum(cwidths),lx)
#     sxx[7]=lx-35;sxx[8]=lx-20;sxx[9]=lx-7
 
#     nr=length(ttt)-1
#     case_data0=NULL
#         for(j in 1:nr){
 
#             rx=t(substring(ttt[[j]],sxx[-(length(sxx))],sxx[-c(1)]-1))
#             rx2=trimws(rx, which ="both")
#             case_data0=rbind(case_data0,rx2)
#         }   
 
# case_data=rbind(case_data,case_data0)
# }
 
# case_data_df=data.frame(case_data[-which(case_data[,1]==""),])
# names(case_data_df)=c("Case","County","Age","Gender","Travel","Origin","Contact","Jurisdiction","Case_Date")
 
# save_path=paste0("C:\\YOURFOLDER\\LOCATION\\HERE",str_replace_all(Sys.Date(),"-","_"),".csv")
# write.csv(case_data_df,save_path,row.names=F)