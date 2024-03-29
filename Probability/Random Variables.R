rm(list = ls())
options(digits = 4)
library(imager); library(gtools); library(tidyverse); library(ggplot2)

## Being able to quantify the uncertainty introduced by randomness is one of the most important jobs of a data analyst. Statistical 
## inference offers a framework, as well as several practical tools, for doing this. The first step is to learn how to mathematically
## describe random variables.

## In this chapter, we introduce random variables and their properties starting with their application to games of chance. We then
## describe some of the events surrounding the financial crisis of 2007-200850 using probability theory. This financial crisis was 
## in part caused by underestimating the risk of certain securities51 sold by financial institutions. Specifically, the risks of 
## mortgage-backed securities (MBS) and collateralized debt obligations (CDO) were grossly underestimated. These assets were sold 
## at prices that assumed most homeowners would make their monthly payments, and the probability of this not occurring was calculated 
## as being low. A combination of factors resulted in many more defaults than were expected, which led to a price crash of these
## securities. As a consequence, banks lost so much money that they needed government bailouts to avoid closing down completely.



# Random Variables --------------------------------------------------------

"Random variables are numeric outcomes resulting from random processes"
## For example, define X to be 1 if a bead is blue and red otherwise:
beads = rep(c("red", "blue"), times = c(2,3))
X = ifelse(sample(beads, 1) == "blue", 1, 0)
## Here X is a random variable: every time we select a new bead the outcome changes randomly
X = replicate(100, ifelse(sample(beads, 1) == "blue", 1, 0)); X



# Sampling models ---------------------------------------------------------

## Many data generation procedures, those that produce the data we study, can be modeled quite well as draws from an urn.  In 
## epidemiological studies, we often assume that the subjects in our study are a random sample from the population of interest. 
## The data related to a specific outcome can be modeled as a random sample from an urn containing the outcome for the entire 
## population of interest. Similarly, in experimental research, we often assume that the individual organisms we are studying, 
## for example worms, flies, or mice, are a random sample from a larger population.

## Suppose a very small casino hires you to consult on whether they should set up roulette wheels. To keep the example simple, 
## we will assume that 1,000 people will play and that the only game you can play on the roulette wheel is to bet on red or black. 
## The casino wants you to predict how much money they will make or lose. They want a range of values and, in particular, they want 
## to know what’s the chance of losing money. If this probability is too high, they will pass on installing roulette wheels.

## We are going to define a random variable S that will represent the casino’s total winnings. Let’s start by constructing the urn.
## A roulette wheel has 18 red pockets, 18 black pockets and 2 green ones. So playing a color in one game of roulette is equivalent
## to drawing from this urn:
color <- rep(c("Black", "Red", "Green"), c(18, 18, 2))
## The 1,000 outcomes from 1,000 people playing are independent draws from this urn. If red comes up, the gambler wins and the casino
## loses a dollar, so we draw a -$1. Otherwise, the casino wins a dollar and we draw a $1. 
X = sample(ifelse(color == "Red", -1, 1), 1000, replace = T); X[1:10] # sample understands the data to randomize from is color
## We can also generate results like this
X = sample(c(1,-1), 1000, replace = T, prob = c(18/38, 20/38))
"We call this a sampling model since we are modeling the random behavior of roulette with the sampling of draws from an urn. 
 The total winnings S is simply the sum of these 1,000 independent draws:"
S = sum(X); S
## We can then compute the estimated expected gain through a Monte Carlo experiment
gains = replicate(10000, sample(c(-1, 1), 1000, replace = T, prob = c(18/38, 20/38)) %>% sum())
mean(gains)



# The probability distribution of a random variable -----------------------

"If you run the code above, you see that S changes every time. This is, of course, because S is a random variable."

"Note that if we can define a cumulative distribution function F(a) = P(S <= a), then we will be able to answer any question 
 related to the probability of events defined by our random variable S, including the event S<0. We call this F the random 
 variable’s distribution function."


"We can estimate the distribution function for the random variable S by using a Monte Carlo simulation to generate many realizations
 of the random variable."
S = replicate(10000, sample(c(-1, 1), 1000, replace = T, prob = c(18/38, 20/38)) %>% sum())
mean(S)
## Now we can ask the following: in our simulations, how often did we get sums less than or equal to a? This will be a very good 
## approximation of F(a) 
mean(S < 0)
hist(S, freq = F, breaks = 25)

## We see that the distribution appears to be approximately normal. A qq-plot will confirm that the normal approximation is close 
## to a perfect approximation for this distribution. If, in fact, the distribution is normal, then all we need to define the 
## distribution is the average and the standard deviation. Because we have the original values from which the distribution is 
## created, we can easily compute these with mean(S) and sd(S). The blue curve you see added to the histogram above is a normal 
## density with this average and standard deviation.
ggplot(data.frame(S), aes(sample = scale(S))) +
  geom_qq() + geom_abline()
"This average and this standard deviation have special names. They are referred to as the expected value and standard error of 
 the random variable S"


"Statistical theory provides a way to derive the distribution of random variables defined as independent random draws from an urn.
 Specifically, in our example above, we can show that  (S+n)/2 follows a binomial distribution. We therefore do not need to run 
 for Monte Carlo simulations to know the probability distribution of S :
 P(S < 0) = P((S + n)/2 < (a + n)/2)"
## P(S < 0) proba to lose after 1000 games
pbinom(1000 / 2, size = 1000, prob = 20/38)
## Because this is a discrete probability function,to get P(S<0) rather than P(S<=0), we write:
pbinom(1000 / 2 - 1, size = 1000, prob = 20/38)
## Before with Monte Carlo we found that on 1000 games we won on average of 52-53
## P(S < 52.5) proba to win less than 100 after 10000 games
pbinom((1000 + 52.5) / 2 - 1, size = 1000, prob = 20/38) # the probability to win less than 52.5 is a bit under 50%






# The expected value and standard error -----------------------------------

"Using the definition of standard deviation, we can derive, with a bit of math, that if an urn contains two values a and b with 
 proportions p and (1-p), the standard deviation is:"
                                                        "|b - a|.(p(1-p))^1/2"
## In the roulette example :
2 * sqrt(10/19 * (9/19))
## the random variable defined by one draw has an expected value of 0.05 and a standard error of about 1. This makes sense since we 
## either get 1 or -1, with 1 slightly favored over -1.

"Empirical"
gains = sample(c(-1, 1), 1000000, replace = T, prob = c(18/38, 20/38))
mean(gains)
sd(gains)
## Over 1,000,000 games
sum(gains)


"Theoretical"
"E[X] = a.p + b.(1-p)"
expected = 1*20/38 - 1*18/38
stdev = 2 * sqrt(10/19 * (9/19))
## Over 1,000,000 games
1000000*expected
"If our draws are independent, then the standard error of the sum is given by the equation"
sqrt(1000000) * stdev ## standard error

## As a result, when 1,000,000 people bet on red, the casino is expected to win $52,631 with a standard error of about $1,000. 
## It therefore seems like a safe bet. But we still haven’t answered the question: how likely is it to lose money? Here the Central
## Limit Theorem will help.

"Advanced note: Before continuing we should point out that exact probability calculations for the casino winnings can be performed 
 with the binomial distribution. However, here we focus on the CLT, which can be generally applied to sums of random variables in a
 way that the binomial distribution can’t."


#  Population SD versus the sample SD -------------------------------------

## sd() does not return the sd of the list, but rather uses a formula that estimates standard deviations of a population from a 
## random sample X1,...,Xn which divide the sum of squares by n-1 (this is because when we work with samples we also estimate
## the mean, so we lose a degree of freedom)
"adjusted standard error = sqrt(1 / (n-1)) * standard deviation" # erreur-type corrigé

## For all the theory discussed here, you need to compute the actual standard deviation as defined: 
"sqrt(mean((x-m)^2))" # non adjusted standard dev





#  Central Limit Theorem --------------------------------------------------

"The Central Limit Theorem (CLT) tells us that when the number of draws, also called the sample size, is large, the probability 
 distribution of the sum of the independent draws is approximately normal. Because sampling models are used for so many data 
 generation processes, the CLT is considered one of the most important mathematical insights in history."

## Therefore the theoretical values above match those obtained with a Monte Carlo simulation
## So using the CLT, we can skip the Monte Carlo simulation and instead compute the probability of the casino losing money using
## the approximation of the mean and the standard error

"How large is large in the Central Limit Theorem?"
## The CLT works when the number of draws is large. But large is a relative term. In many circumstances as few as 30 draws is 
## enough to make the CLT useful. In some specific instances, as few as 10 is enough. However, these should not be considered 
## general rules. Note, for example, that when the probability of success is very small, we need much larger sample sizes.




# Statistical properties of averages --------------------------------------

## The expected value of the sum of random variables is the sum of each random variable’s expected value. We can write it like this:
"E[X1 + ... + Xn] = E[X1] + ... + E[Xn]"
## If the X are independent draws from the urn, then they all have the same expected value. Let’s call it μ and thus: 
"E[X1 + ... + Xn] = nμ"

## The expected value of a non-random constant times a random variable is the non-random constant times the expected value of a
## random variable.
"E[aX] = a.E[X]"

## For independent variables :
"SE[X1 + ... + Xn] = √(SE[X1]^2 + ... + SE[Xn]^2) = √(V[X1] + ... + V[Xn])"

## The standard error of a non-random constant times a random variable is the non-random constant times the standard error.
"SE[aX] = a.SE[X] <=> V[aX] = a^2.V[X]"

## If X is normally distributed ans a and b are constants, then aX + b is also normally distributed
## All we are doing is changing the units of the random variable by multiplying by a then shifting the center by b



# Law of large numbers ----------------------------------------------------

"An important implication of the final result is that the standard error of the average becomes smaller and smaller as n grows larger.
 When n is very large, then the standard error is practically 0 and the average of the draws converges to the average of the urn"

## The law of averages is sometimes misinterpreted. For example, if you toss a coin 5 times and see a head each time, you might hear 
## someone argue that the next toss is probably a tail because of the law of averages: on average we should see 50% heads and 50% 
## tails. A similar argument would be to say that red “is due” on the roulette wheel after seeing black come up five times in a row. 
## These events are independent so the chance of a coin landing heads is 50% regardless of the previous 5. This is also the case for
## the roulette outcome. The law of averages applies only when the number of draws is very large and not in small samples. After a 
## million tosses, you will definitely see about 50% heads regardless of the outcome of the first five tosses.





# DataCamp Assessment -----------------------------------------------------

"Betting on green in the roulette game"
# Assign a variable `p_green` as the probability of the ball landing in a green pocket
p_green <- 2 / 38
# Assign a variable `p_not_green` as the probability of the ball not landing in a green pocket
p_not_green <- 1-p_green
# Define the number of bets using the variable 'n'
n <- 100
# Calculate 'avg', the expected outcome of 100 spins if you win $17 when the ball lands on green and you lose $1 when the ball doesn't land on green
avg <- n * (17*p_green + -1*p_not_green)
# Compute 'se', the standard error of the sum of 100 outcomes
se <- sqrt(n) * (17 - -1)*sqrt(p_green*p_not_green)
# Using the expected value 'avg' and standard error 'se', compute the probability that you win money betting on green 100 times.
1 - pnorm(0, avg, se)

"Monte Carlo"
# The variable `B` specifies the number of times we want the simulation to run. Let's run the Monte Carlo simulation 10,000 times.
B <- 10000
# Use the `set.seed` function to make sure your answer matches the expected result after random sampling
set.seed(1)
# Create an object called `S` that replicates the sample code for `B` iterations and sums the outcomes.
S = replicate(B, sum(sample(c(17, -1), n, replace = T, prob = c(p_green, p_not_green))))
# Compute the average value for 'S'
mean(S)
# Calculate the standard deviation of 'S'
sd(S)
# Calculate the proportion of outcomes in the vector `S` that exceed $0
mean(S>0)

"Average winnings per bet"
# Define the number of bets using the variable 'n'
n <- 10000
# Create a vector called `X` that contains the outcomes of `n` bets
X = sample(c(17, -1), n, prob = c(p_green, p_not_green), replace = T)
# Define a variable `Y` that contains the mean outcome per bet. Print this mean to the console.
Y = mean(X)

# Calculate the expected outcome of `Y`, the mean outcome per bet in 10,000 bets
p_green*17 - p_not_green
# Compute the standard error of 'Y', the mean outcome per bet from 10,000 bets.
abs(17 - -1)*sqrt(p_green*p_not_green) / sqrt(n)

# We defined the average using the following code
avg <- 17*p_green + -1*p_not_green
# We defined standard error using this equation
se <- 1/sqrt(n) * (17 - -1)*sqrt(p_green*p_not_green)
# Given this average and standard error, determine the probability of winning more than $0. Print the result to the console.
1 - pnorm(0, avg, se)


"Create a Monte Carlo simulation that generates 10,000 outcomes of S, the average outcome from 10,000 bets on green."
# The variable `n` specifies the number of independent bets on green
n <- 10000
# The variable `B` specifies the number of times we want the simulation to run
B <- 10000
# Use the `set.seed` function to make sure your answer matches the expected result after random number generation
set.seed(1)
# Generate a vector `S` that contains the the average outcomes of 10,000 bets modeled 10,000 times
S = replicate(B, mean(sample(c(17,-1), n, prob = c(p_green, p_not_green), replace = T)))
# Compute the average of `S`
mean(S)
# Compute the standard deviation of `S`
sd(S)
# Compute the proportion of outcomes in the vector 'S' where you won more than $0
mean(S>0)
"Approximations are now much closer"





# edX Assessment ----------------------------------------------------------

"An old version of the SAT college entrance exam had a -0.25 point penalty for every incorrect answer and awarded 1 point for a correct answer. 
 The quantitative test consisted of 44 multiple-choice questions each with 5 answer choices. Suppose a student chooses answers by guessing for 
 all questions on the test."
# What is the probability of guessing correctly for one question?
0.2
# What is the expected value of points for guessing on one question?
avg = 0.2*1-0.8*0.25 # 0
# What is the expected score of guessing on all 44 questions?
44 * avg
# What is the standard error of guessing on all 44 questions?
se = sqrt(44) * abs(1 - -0.25)*sqrt(0.2*0.8)
# Use the Central Limit Theorem to determine the probability that a guessing student scores 8 points or higher on the test.
1-pnorm(8, avg, se)
# Set the seed to 21, then run a Monte Carlo simulation of 10,000 students guessing on the test.
set.seed(21, sample.kind = "Rounding")
Y = replicate(10000, sum(sample(c(-0.25, 1), 44, replace = T, prob = c(0.8, 0.2))))
mean(Y>=8)

"The SAT was recently changed to reduce the number of multiple choice options from 5 to 4 and also to eliminate the penalty for guessing."
# What is the expected value of the score when guessing on this new test?
avg2 = 0.25*1 # 0.2
44 * avg2
# Consider a range of correct answer probabilities representing a range of student skills. What is the lowest p such that the probability of 
# scoring over 35 exceeds 80%?
p <- seq(0.25, 0.95, 0.05)
X = 44 * p
prob_over_35 = 1 - pnorm(35, X, sqrt(p*(1-p))) %>% round(3); data.frame(p, prob_over_35)

"A casino offers a House Special bet on roulette, which is a bet on five pockets (00, 0, 1, 2, 3) out of 38 total pockets. The bet pays out 6 
 to 1. In other words, a losing bet yields -$1 and a successful bet yields $6. A gambler wants to know the chance of losing money if he places
 500 bets on the roulette House Special."
# What is the expected value of the payout for one bet?
avg = 6*5/38 - 33/38; avg
# What is the standard error of the payout for one bet?
se = abs(6 - -1) * sqrt(5/38 * 33/38); se
# What is the expected value of the average payout over 500 bets?
avg
# What is the standard error of the average payout over 500 bets?
se_over500 = (1/sqrt(500)) * se; se_over500
# What is the expected value of the sum of 500 bets?
avg_sum = avg*500; avg_sum
# What is the standard error of the sum of 500 bets?
se_sum = se * sqrt(500); se_sum
# Use pnorm() with the expected value of the sum and standard error of the sum to calculate the probability of losing money over 500 bets
pnorm(0, avg_sum, se_sum)





