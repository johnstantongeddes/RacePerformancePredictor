# Race Performance Prediction
John Stanton-Geddes  
May 19, 2015  

Avoiding the [Wall](https://www.youtube.com/watch?v=6pttqFUviWs) in a marathon requires careful pacing over the first half of the race. Given the length of the race and the time it takes to recover, most runners only attempt a marathon race a 1-2 times a year, making it difficult to accurately predict their target pace. The most widely-used [methods for predicting performance](http://run-down.com/statistics/calcs_explained.php) are all pretty [old](http://www.cs.uml.edu/~phoffman/xcinfo3.html). As a statistician, these methods also frustrate me in not providing a target range. In this report, I use empirical observations of personal bests available from www.athlinks.com to derive a new and improved marathon performance predictor.

The ultimate goal is to answer the question *what should my goal for a marathon be based on a recent half-marathon performance?*  






# Data

I collected personal best times from a haphazard sample of athletes on (http://www.athlinks.com/) that had a marathon best time listed. To select the best data possible, I pulled results for the top 100 athletes from 15 regions, sorted by  `Race Count`, under the assumption that athletes with the most races would be more likley to have complete data (see details in `getPBdata.R` script). Further data cleaning yielded data a total of 1,333 athletes.

For these athletes, the plot of distance against race time shows a wider range at longer distances, as would be expected.

![](RacePerformancePredictor_files/figure-html/eda-1.png) 

Grouping by gender and plotting on a log-scale, we see that men (blue) tend to be faster than women (red lines) at all distances.

![](RacePerformancePredictor_files/figure-html/eda2-1.png) 

However, grouping by gender ignores significant variation among athletes in performance. I calculated each athletes 'rank' in comparison to all other athletes in the dataset, and took their average rank across distances. As the dataset includes national caliber (e.g. 61 minute half-marathon) to much slower (e.g. 3 hour half-marathon) runners, this is representative of the entire US running population. 

In this figure, it appears that highly-ranked runners (Rank top 1-5%, darker lines) slow down less than recreational runners (Rank > 75%, lighter lines). 

![](RacePerformancePredictor_files/figure-html/rank-1.png) 

# Method 1: predict change in pace with increasing distance

First, I tried to emulate methods that predict how much a runner's pace decreases in races of increasing distance. As the function of race time against distance appears to be nearly linear, I fit a linear model with a second-order polynomial to allow for slowing over longer distances, variables for gender and athlete rank, and allowed for interactions among all these.  

This figure shows the predicted values from the model (black lines) at Ranks of 10%, 50% and 90% for a male runner, against the raw data plotted in gray. This looks like a pretty good model!

![](RacePerformancePredictor_files/figure-html/prediction-1.png) 



Intermediate to answering my ultimate question, I explored how much athletes of different ranks slowed down in races of increasing distances. From my observation above, I hypothesized that faster runners would slow less than slower runners. 

![](RacePerformancePredictor_files/figure-html/slowdown-1.png) 

The above figure supports this hypothesis! Runners ranked in the top 10% only slow down by ~6% from the half to full marathon, whereas runners at the 90% rank slow by ~12%. 

# And my prediction is...



Taking this to a personal level, using my most recent half-marathon (1:12:22, 5th percentile) and the 5^th^ and 50^th^ percentiles as brackets, my predicted performance at a marathon is between 02:32:52 and 02:38:31.

While the fast end of my predictions is on par with the current [performance calculators](http://www.runningforfitness.org/calc/racepaces/rp/rpother?dist=13.1&units=miles&hr=1&min=12&sec=23&age=33&gender=M&Submit=Calculate), the slow end is quite a bit slower, indicating that these tools may be setting unrealistic expectations for most runners!

The problem with this approach is that my estimate range came from my own expectations of my performance. 

# Method 2: predict time directly

In the previous section, I used data on times across distances to predict how much a runner's pace slows down as the distance increases. An alternate approach is to directly predict a marathon time from a half-marathon or other race time. After exploring a few different statistical models, here's the output from my best model, including half-marathon time, gender and the interaction between these predictors.


```
## Analysis of Variance Table
## 
## Response: maratime
##                             Df     Sum Sq    Mean Sq   F value    Pr(>F)
## poly(hmaratime, 2)           2 6176318657 3088159329 1635.2689 < 2.2e-16
## gender                       1       1618       1618    0.0009    0.9767
## poly(hmaratime, 2):gender    2   49805763   24902881   13.1868  2.14e-06
## Residuals                 1300 2455013405    1888472                    
##                              
## poly(hmaratime, 2)        ***
## gender                       
## poly(hmaratime, 2):gender ***
## Residuals                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

The model output shows that half-marathon time and athlete rank are important predictors of marathon time, but gender doesn't matter when these factors are accounted for. Using this model, my marathon prediction is between **02:32:44 and 02:36:03**, which falls in the middle of the range from the pace slow-down approach above. This also supports the conclusion that current marathon performance predictors produce overly optimistic predictions for most runners.

# Model Performance

Some friends pointed out that I'm not exactly an independent measure. So, I grabbed recent half-marathon times from the [New Bedford Half Marathon](http://static.djlmgdigital.com.s3.amazonaws.com/nbt/southcoasttoday/graphics/pdf/2015HalfMarathonResults.pdf) and the [Marathon Unplugged]() for 22 USATF New England runners that competed in the [marathon]() (and were unaware of this analysis). I then used the model to predict their marathon times and compare to the actual results.

This figure shows the deviation from each runner's observed marathon time and their predicted time from my model. Negative values mean they ran faster then the prediction, while positive means they ran slower.


![](RacePerformancePredictor_files/figure-html/other_runners-1.png) 

This *simple* model had a median error of only 29.5 seconds for these 22 runners! This result far excited my expectations. 

That said, the prediction was quite variable. Exactly half (11) of my test observations were faster, and thus half were slower. The prediction error for the slower result had a longer skew though, which is to be expected; when you blow up at a marathon, you *really* slow down. 

For fun, here are a few specific examples:

*New Bedford*

- Matt Pelletier (VCM winner) - 1:07:09
- Teage O'Connor - 1:08:47
- Binney Mitchell - 1:17:31
- Pascal Cheng    - 1:41:16

*Unplugged*

- Tom Thurston    - 1:18:04


|     Runner      |  Predicted  |  Actual  |  Error  |
|:---------------:|:-----------:|:--------:|:-------:|
| Matt Pelletier  |  02:18:11   | 2:19:12  |  60.92  |
| Teage O'Connor  |  02:23:20   | 2:33:32  |  612.1  |
| Binney Mitchell |  02:49:27   | 2:57:12  |  465.1  |
|  Pascal Cheng   |  03:48:31   | 3:27:07  |  -1284  |
|  Tom Thurston   | 02:51:0.87  | 2:41:53  | -547.9  |

Also not bad! Prediction was only 60 seconds slow for the winner. 10 minutes too fast for Teage, but 2:23 was his goal time. Tom Thurston and Pascal Cheng are both talented masters runners with plenty of marathon experience, which showed as they ran 10 and 20 10 minutes *faster* than their predicted times!


# Notes and Such

This analysis done in [R](http://www.r-project.org/) using [RStudio](http://www.rstudio.com/) and these helpful packages. Special thanks to [rvest](http://blog.rstudio.org/2014/11/24/rvest-easy-web-scraping-with-r/) for making the web-scraping possible.


```
## R version 3.1.1 (2014-07-10)
## Platform: x86_64-apple-darwin13.1.0 (64-bit)
## 
## locale:
## [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] dplyr_0.4.1.9000 plyr_1.8.1       tidyr_0.2.0      pander_0.5.1    
## [5] lubridate_1.3.3  ggplot2_1.0.1    stringr_0.6.2   
## 
## loaded via a namespace (and not attached):
##  [1] assertthat_0.1       colorspace_1.2-6     DBI_0.3.1           
##  [4] digest_0.6.8         evaluate_0.6         formatR_1.1         
##  [7] grid_3.1.1           gtable_0.1.2         htmltools_0.2.6     
## [10] knitr_1.9            labeling_0.3         lazyeval_0.1.10.9000
## [13] magrittr_1.5         MASS_7.3-40          memoise_0.2.1       
## [16] munsell_0.4.2        parallel_3.1.1       proto_0.3-10        
## [19] Rcpp_0.11.5          reshape2_1.4.1       rmarkdown_0.5.1     
## [22] scales_0.2.4         tools_3.1.1          yaml_2.1.13
```
