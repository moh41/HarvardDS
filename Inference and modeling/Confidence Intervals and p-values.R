rm(list = ls())
options(digits = 3)
library(imager); library(gtools); library(tidyverse); library(ggplot2); library(dslabs)



# Confidence intervals ---------------------------------------

"Confidence intervals are a very useful concept widely employed by data analysts. A version of these that are commonly seen come from 
 the ggplot geometry geom_smooth. Here is an example using a temperature dataset available in R:"
plot(load.image("https://rafalab.github.io/dsbook/book_files/figure-html/first-confidence-intervals-example-1.png"))

## In the Machine Learning part we will learn how the curve is formed, but for now consider the shaded area around the curve. This is 
## created using the concept of confidence intervals.

## We want to know the probability that the interval [X-1.96se, X+1.96se] contains the reue porportion p. First, consider that the start 
## and end of these intervals are random variables: every time we take a sample, they change.
"P(X-1.96se < p < X+1.96se)" ## we scale it (-X/se)
"P(-1.96 < (p-X)/se < 1.96)"
"P(-1.96 < Z < 1.96)"
pnorm(1.96) - pnorm(-1.96)
## We can find the quantile like this
"Here we want 95% confidence on a bilateral interval, so 97.5% on each side"
qnorm(0.975) #> 1.96
## If we want 99% confidence we ask for 0.5% on each side
qnorm(0.995) #> 2.58




# Monte Carlo simulation --------------------------------------------------

## We can run a Monte Carlo simulation to confirm that, in fact, a 95% confidence interval includes p 95% of the time.
p = 0.5
inside <- replicate(10000, {
  x <- sample(c(0,1), 1000, replace = TRUE, prob = c(1-p, p))
  x_hat <- mean(x)
  se_hat <- sqrt(x_hat * (1 - x_hat) / 1000)
  between(p, x_hat - 1.96 * se_hat, x_hat + 1.96 * se_hat) ## returns true if in th interval
})
mean(inside)

## The following plot shows the first 100 confidence intervals. In this case, we created the simulation so the black line 
## denotes the parameter we are trying to estimate:
plot(load.image("https://rafalab.github.io/dsbook/book_files/figure-html/confidence-interval-coverage-1.png"))

## Saying the p has a 95% chance of being between this and that is technically an incorrect statement because p is not random.




# Power  -----------------------------------------------------------

"In the case of small sample size, we could get an interval including 0, which is for example not possible for polls
 It's called a lack of power and can only be fixed by increasing the size of the sample
 In the context of polls, power can be defined as the probability to find a spread different from 0, allowing us to conclude
 on the direction of the spread"




# p-values ----------------------------------------------------------------

## P-value for X_hat = 0.52 being different from p_h0 = 0.5 on a n = 100 sample
X_hat = 0.52; p_h0 = 0.5
se = sqrt(0.5*0.5/100); z = (X_hat - p_h0) /se
pvalue = 1 - (pnorm(z) - pnorm(-z)) # area under the curve beyond [-z,z]
plot(load.image("https://courses.edx.org/assets/courseware/v1/1d6d6ea2651ed47bf275449ed012f2a1/asset-v1:HarvardX+PH125.4x+1T2020+type@asset+block/pvalue-normal-dist.jpg"))

"The p-value is the area under the curve of the theoretical distribution beyond the interval [-z,z]
 It represents the highest confidence level we can have to accept the null hypothesis h0
 The lowest the p-value the highest the doubt on the compared value p_h0 is
 It is the probability to be right accepting the null hypothesis
 So it is also the highest confidence level (alpha) for which we can construct a confidence interval that will include p_h0
 Symmetrically we can construct the acceptation interval arround p_h0 and see if it includes X_bar/X_hat, the p-value is the same
 The pvalue depends on the estimate value and the sample size -> finding the same estimate on more observations would reduce the 
 p-value because when N is larger we should find a more precise estimate" 

## So here we find a pvalue=68.9% maximum confidence level to accept h0 : "p = 0.5" 
## It also mean we still have more than 30% of risk while affirming the real value is 0.5
## In statistics however we consider that a p-value over 10% isn't small enough to say that the real value is significantly 
## different from the compared value p_h0, here 0.5





# DataCamp Assessment -----------------------------------------------------

library(dslabs)
data("polls_us_election_2016")
## We will use all the national polls that ended within a few weeks before the election.

"Assume there are only two candidates and construct a 95% confidence interval for the election night proportion p."
# Generate an object `polls` that contains data filtered for polls that ended on or after October 31, 2016 in the United States
polls = filter(polls_us_election_2016, enddate >= "2016-10-31", state == "U.S.")
# How many rows does `polls` contain? Print this value to the console.
nrow(polls)
# Assign the sample size of the first poll in `polls` to a variable called `N`. Print this value to the console.
N = polls$samplesize[1]
N
# For the first poll in `polls`, assign the estimated percentage of Clinton voters to a variable called `X_hat`. 
# Print this value to the console.
X_hat = polls$rawpoll_clinton[1]/100
X_hat
# Calculate the standard error of `X_hat` and save it to a variable called `se_hat`. Print this value to the console.
se_hat = sqrt(X_hat*(1-X_hat)/N)
se_hat
# Use `qnorm` to calculate the 95% confidence interval for the proportion of Clinton voters. Save the lower and then 
# the upper confidence interval to a variable called `ci`.
z = qnorm(0.975)
ci = c(X_hat - z*se_hat, X_hat + z*se_hat)

"Create a new object called pollster_results that contains the pollster's name, the end date of the poll, the proportion
 of voters who declared a vote for Clinton, the standard error of this estimate, and the lower and upper bounds of the
 confidence interval for the estimate."
# Use the mutate function to define four new columns: X_hat, se_hat, lower, and upper. Temporarily add these columns to 
# the polls object that has already been loaded for you.
polls = mutate(polls, X_hat = (d_hat+1)/2, 
               se_hat = 2*sqrt(X_hat*(1-X_hat)/samplesize), 
               lower = d_hat - qnorm(0.975)*se_hat, 
               upper = d_hat + qnorm(0.975)*se_hat)
# Use the select function to select the columns from polls to save to the new object pollster_results.
pollster_results = select(polls, pollster, enddate, d_hat, lower, upper)
pollster_results


"The final tally for the popular vote was Clinton 48.2% and Trump 46.1%. Add a column called hit to pollster_results that 
 states if the confidence interval included the true proportion p=0.482 or not. What proportion of confidence intervals 
 included p?"
# # Add a logical variable called `hit` that indicates whether the actual value exists within the confidence interval of each 
# poll. Summarize the average `hit` result to determine the proportion of polls with confidence intervals include the actual 
# value. Save the result as an object called `avg_hit`.
avg_hit <- mutate(pollster_results, hit = 0.482 >= lower & 0.482 <= upper) %>% summarize(mean(hit))
#> 31.4 % made a good forecast << 95%

"If these confidence intervals are constructed correctly, and the theory holds up, what proportion of confidence intervals 
 should include p?"
0.95


"A much smaller proportion of the polls than expected produce confidence intervals containing p. Notice that most polls that fail 
 to include p are underestimating. The rationale for this is that undecided voters historically divide evenly between the two main 
 candidates on election day."
# Add a statement to this line of code that will add a new column named `d_hat` to `polls`. The new column should contain the difference 
# in the proportion of voters.
polls <- polls_us_election_2016 %>% filter(enddate >= "2016-10-31" & state == "U.S.") %>%
                                    mutate(d_hat = (rawpoll_clinton - rawpoll_trump)/100)
# Assign the difference `d_hat` of the first poll in `polls` to a variable called `d_hat`. Print this value to the console.
d_hat = polls$d_hat[1]
# Assign proportion of votes for Clinton to the variable `X_hat`.
X_hat = (d_hat+1)/2 # because we assume there are only two candidates
# Calculate the standard error of the spread and save it to a variable called `se_hat`. Print this value to the console.
se_hat = sqrt(X_hat*(1-X_hat)/N)*2
# Use `qnorm` to calculate the 95% confidence interval for the difference in the proportions of voters. Save the lower and then the upper
# confidence interval to a variable called `ci`.
z = qnorm(0.975)
ci = c(d_hat - z*se_hat, d_hat + z*se_hat)


"Create a new object called pollster_results that contains the pollster's name, the end date of the poll, the difference in the proportion
 of voters who declared a vote either, and the lower and upper bounds of the confidence interval for the estimate."
# Use the mutate function to define four new columns: 'X_hat', 'se_hat', 'lower', and 'upper'. Temporarily add these columns to the polls 
# object that has already been loaded for you.
polls = mutate(polls, X_hat = (d_hat+1)/2,
               se_hat = 2*sqrt(X_hat*(1-X_hat)/samplesize),
               lower = d_hat - qnorm(0.975)*se_hat, 
               upper = d_hat + qnorm(0.975)*se_hat)
pollster_results = polls %>% select(pollster, enddate, d_hat, lower, upper)

"What proportion of confidence intervals for the difference between the proportion of voters included d, the actual difference in election day?"
# Add a logical variable called `hit` that indicates whether the actual value (0.021) exists within the confidence interval of each poll. 
# Summarize the average `hit` result to determine the proportion of polls with confidence intervals include the actual value. Save the 
# result as an object called `avg_hit`.
avg_hit <- mutate(pollster_results, hit = 0.021 >= lower & 0.021 <= upper) %>% summarize(mean(hit))
#> 77.1 %


"Although the proportion of confidence intervals that include the actual difference between the proportion of voters increases substantially, 
 it is still lower that 0.95. In the next chapter, we learn the reason for this."


"To motivate our next exercises, calculate the difference between each poll's estimate d? and the actual d=0.021. Stratify this difference, or error, 
 by pollster in a plot."
# Add variable called `errors` to the object `polls` that contains the difference between d_hat and the actual difference on election day. Then make a 
# plot of the error stratified by pollster.
polls = polls %>% mutate(errors = d_hat - 0.021)
polls %>% group_by(pollster) %>% filter(n() >= 5) %>% ## n() counts the occurences of each group generated
  ggplot(aes(errors, pollster)) +
  geom_point() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))








