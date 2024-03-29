rm(list=ls())

## Data visualization is the strongest tool of what we call exploratory data analysis (EDA)
## We are reminded of the saying "a picture is worth a thousand words". Data visualization provides a powerful 
## way to communicate a data-driven finding. In some cases, the visualization is so convincing that no follow-up 
## analysis is required.

## As an example, consider that measurement devices sometimes fail and that most data analysis procedures are not 
## designed to detect these. Yet these data analysis procedures will still give you an answer. The fact that it can
## be difficult or impossible to notice an error just from the reported results makes data visualization particularly 
## important.

library(dplyr)
library(ggplot2)

"A reason ggplot2 is easy for beginners is that its default behavior is carefully chosen to satisfy the great 
 majority of cases and is visually pleasing. As a result, it is possible to create informative and elegant graphs 
 with relatively simple and readable code.

 One limitation is that ggplot2 is designed to work exclusively with data tables in tidy format (where rows are 
 observations and columns are variables). However, a substantial percentage of datasets that beginners work with 
 are in, or can be converted into, this format. An advantage of this approach is that, assuming that our data is 
 tidy, ggplot2 simplifies plotting code and the learning of grammar for a variety of plots."

## Cheat sheet of ggplot2 - useful ressource
"https://rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf"


# Components of a graph ---------------------------------------------------


"Data: The US murders data table is being summarized. We refer to this as the data component."

"Geometry: The plot above is a scatterplot. This is referred to as the geometry component. Other possible 
 geometries are barplot, histogram, smooth densities, qqplot, and boxplot. We will learn more about these 
 in the Data Visualization part of the book."

"Aesthetic mapping: The plot uses several visual cues to represent the information provided by the dataset. 
 Each point represents a different observation, and we map data about these observations to visual cues like 
 x- and y-scale. Color is another visual cue that we map to region. We refer to this as the aesthetic mapping 
 component. How we define the mapping depends on what geometry we are using."

## The points are labeled with the state abbreviations.
## The range of the x-axis and y-axis appears to be defined by the range of the data. They are both on log-scales.
## There are labels, a title, a legend, and we use the style of The Economist magazine.




# ggplot2 objects, geometries, mappings ---------------------------------------------------------

library(dslabs)
data(murders)

## The first step in creating a ggplot2 graph is to define a ggplot object.
ggplot(data = murders)
## It renders a plot, in this case a blank slate since no geometry has been defined. The only style choice 
## we see is a grey background.

"In ggplot2 we create graphs by adding layers. Layers can define geometries, compute summary statistics, 
 define what scales to use, or even change styles. To add layers, we use the symbol +"


## Usually, the first added layer defines the geometry. We want to make a scatterplot. Taking a quick look at
## the cheat sheet, we see that the function used to create plots with this geometry is geom_point.
## Geometry function names follow the pattern: geom_X where X is the name of the geometry. Some examples include 
## geom_point, geom_bar, and geom_histogram.

## For geom_point() to run properly we need to provide data and a mapping. Data is already provided through the ggplot
## To find out what mappings are expected, we read the Aesthetics section of the help file geom_point help file:
?geom_point
"x, y, alpha.... are the arguments that can be customized via geom_point"
"x and y are required"


## The aes function connects data with what we see on the graph by defining aesthetic mappings and will be one of the functions 
## you use most often when plotting.
ggplot(data = murders) +
  geom_point(aes(x = population/10^6, y = total))
## We can assign part of a ggplot setup and use it later
p = ggplot(murders)
p + geom_point(aes(x = population, y = total))




# Other layers ------------------------------------------------------------

## The geom_label() and geom_text() functions permit us to add text to the plot with and without a rectangle 
## behind the text, respectively.
ggplot(data = murders) +
  geom_point(aes(x = population, y = total)) +
  geom_text(aes(population, total, label = abb)) ## we specify x and y cause labels are affected to points

## change the point size
ggplot(data = murders) +
  geom_point(aes(x = population, y = total), size = 3) +
  geom_text(aes(population, total, label = abb))
"size is not a mapping: whereas mappings use data from specific observations and need to be inside aes(), operations 
 we want to affect all the points the same way do not need to be included inside aes."

## Moving labels 
ggplot(data = murders) +
  geom_point(aes(x = population, y = total), size = 3) +
  geom_text(aes(population, total, label = abb), nudge_x = 1.5) # all labels are slightly moved to the right



# Global aesthetic mappings -----------------------------------------------

## In the previous line of code, we define the mapping aes(population/10^6, total) twice, once in each geometry. 
## We can avoid this by using a global aesthetic mapping. We can do this when we define the blank slate ggplot 
## object. The function ggplot() contains an argument that permits us to define aesthetic mappings:
ggplot(data = murders, aes(x = population, y = total, label = abb)) +
  geom_point(size = 3) +
  geom_text(nudge_x = 1.5)
"Note that the geom_point function does not need a label argument and therefore ignores that aesthetic.
 If necessary, we can override the global mapping by defining a new mapping within each layer. These local definitions 
 override the global."
ggplot(data = murders, aes(x = population, y = total, label = abb)) +
  geom_point(size = 3) +
  geom_text(aes(x = 20, y = 800, label = "Hi"), size = 10)
  

# Scales ------------------------------------------------------------------

## Change scaling
ggplot(data = murders, aes(x = population, y = total, label = abb)) +
  geom_point(size = 3) +
  geom_text(nudge_x = 0.05) + # need to reduce the nudge
  scale_x_continuous(trans = "log10") +
  scale_y_continuous(trans = "log10")
## This particular transformation is so common that ggplot2 provides the specialized functions
## to rewrite the code like this:
ggplot(data = murders, aes(x = population, y = total, label = abb)) +
  geom_point(size = 3) +
  geom_text(nudge_x = 0.05) +
  scale_x_log10() +
  scale_y_log10() 

## Title and axis labels
murders_plot = ggplot(data = murders, aes(x = population, y = total, label = abb)) +
                geom_text(nudge_x = 0.05) +
                scale_x_log10() +
                scale_y_log10() +
                xlab("Populations in millions (log scale)") + 
                ylab("Total number of murders (log scale)") +
                ggtitle("US Gun Murders in 2010")
murders_plot + geom_point(size = 3) # we removed the geom_point for simplifying the next sections



# More customization ------------------------------------------------------

## Categories as colors
murders_plot + geom_point(size = 3, col = "blue")

## Colors depending on the regions
"A nice default behavior of ggplot2 is that if we assign a categorical variable to color, it automatically 
 assigns a different color to each category and also adds a legend."
murders_plot + geom_point(aes(col = region), size = 3)
## Here we see yet another useful default behavior: ggplot2 automatically adds a legend that maps color to region. 
"To avoid adding this legend we set the geom_point argument show.legend = FALSE."
murders_plot + 
  geom_point(aes(col = region), size = 3) +
  scale_color_discrete(name = "USA Region")

## Plot the average line
## The average murder rate is the type of y = r.x (y and x already plotted here)
## In the log-scale this turns into log(y) = log(r) + log(x)
## -> log(r) is the intercept and the slope of log(x) is 1
avgrate = summarise(murders, avg_rate = sum(total)/sum(population))[1] %>% as.numeric()
murders_plot + 
  geom_point(aes(col = region), size = 3) +
  scale_color_discrete(name = "USA Region") +
  geom_abline(intercept = log10(avgrate), slope = 1, lty = 3, lwd = 1.5, color = "blue")



# Add-on packages - ggthemes and ggrepel ---------------------------------------------------------


## The style of a ggplot2 graph can be changed using the theme functions. Several themes are included as part 
## of the ggplot2 package. In fact, for most of the plots in this book, we use a function in the dslabs package
## that automatically sets a default theme
dslabs::ds_theme_set()
## Many other themes are added by the package ggthemes. Among those are the theme_economist theme that we used. 
## After installing the package, you can change the style by adding a layer like this:
library(ggthemes)
murders_plot = murders_plot + 
  geom_point(aes(col = region), size = 3) +
  scale_color_discrete(name = "USA Region") +
  geom_abline(intercept = log10(avgrate), slope = 1, lty = 3, lwd = 1.5, color = "blue")
murders_plot + theme_economist()
murders_plot + theme_fivethirtyeight()

## The final difference has to do with the position of the labels. In our plot, some of the labels fall on top 
## of each other. The add-on package ggrepel includes a geometry that adds labels while ensuring that they don't
## fall on top of each other. 
library(ggrepel)
"We simply change geom_text with geom_text_repel. Look at the next section"




# All together ------------------------------------------------------------
rm(list=ls())
library(ggplot2); library(ggthemes); library(ggrepel); library(dslabs)
data("murders")

# Population in millions
rate = summarise(murders, avg_rate = sum(total)/sum(population)*10^6)[1] %>% as.numeric()

ggplot(murders, aes(population/10^6, total, label = abb)) +
  geom_point(aes(col = region), size = 3) +
  scale_color_discrete(name = "USA regions") +
  geom_abline(intercept = log10(rate), slope = 1, lty = 3, lwd = 1.5, color = "blue") +
  geom_text_repel() +
  scale_x_log10() +
  scale_y_log10() +
  xlab("Populations in millions (log scale)") + 
  ylab("Total number of murders (log scale)") +
  ggtitle("US Gun Murders in 2010") +
  theme_economist()



# Quick plots with qplot() -------------------------------------------------

## ggplot() requires a data frame and allows us to go deep into customization by reading all informations of the
## data frame. If we only want a simple plot with two vectors we can use base functions like plot(), hist(), etc.
## and qplot()
qplot(murders$population, murders$total) + theme_economist()



# Plot multiple charts ----------------------------------------------------

library(gridExtra)
chart1 = qplot(murders$population)
chart2 = qplot(murders$population, murders$total) + theme_economist()
grid.arrange(chart1, chart2, ncol = 2)

