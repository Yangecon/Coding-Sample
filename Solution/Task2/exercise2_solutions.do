
/*******************************************************************************
  Project	:   
  Author	:   
  Date		:  
  Version	: Stata 16
  

Notes				:	 
Input databases 	: 
Output data			:      
Requiered programs 	:
*******************************************************************************/


*1. Set parameters
program drop _all
clear all
set matsize 10000

*2. Set up  directories, globals, etc.
di "current user: `c(username)'"
if "`c(username)'" == "mariadelmar"{
	global root "/Users/mariadelmar/Dropbox/Predoc 22/Coding Exercise pt2"
}

global input_dir 			= "$root/input"
global intermediate_dir 	= "$root/intermediate"
global output_dir 			= "$root/output"


*3. 


*(a) Create a panel of the variables at the day level 
use "$input_dir/ira_tweets_csv_hashed", clear
gen blm_tweet=regexm(tweet_text, "Black Lives Matter")
replace blm_tweet=1 if (regexm(tweet_text, "BLM")==1)
gen time=substr(tweet_time,1,10)
collapse (count) tweet_count=tweetid (mean) retweet_count reply_count like_count quote_count (sum) blm_tweet, by(time)

gen date=date(time,"YMD")
gen year = year(daily(time, "YMD"))
tsset date, daily

*(b) Timeline
local vars like_count quote_count reply_count retweet_count tweet_count blm_tweet 
label var like_count "Number of likes"
label var quote_count "Number of quotes"
label var reply_count "Number of replies"
label var retweet_count "Number of retweets"
label var tweet_count "Number of total tweets"
label var blm_tweet "Number of blm tweets"

preserve 
	collapse (sum) `vars', by(year)
	tsset year, yearly 
	foreach var of local vars{
	twoway line `var' year 
	graph export "$output_dir/`var'.png"
	}
restore


*(c)  Run the following regression: 

gen event1=date("2015-08-19","20YMD")
gen event2=date("2015-07-13","YMD")
gen event3=date("2016-07-05","YMD")


local vars like_count quote_count reply_count retweet_count tweet_count blm_tweet 

foreach t in  1 2 3{
	preserve
	gen difference_time=date-event`t'
	keep if (inrange(difference_time, -30, 30)==1)
	gen post=(difference_time>=0)
	foreach var of local vars{
			reg `var' post 
			outreg2 using "$output_dir/reg2.xls"
		}
	restore
}





