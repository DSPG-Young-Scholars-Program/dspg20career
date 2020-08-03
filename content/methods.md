### 2020 Veteran Career Pathways Summer Project {style=text-align:center}

### Methodology {style=text-align:center}

#### Sequence Analysis {style=text-align:center}

Sequence analysis refers to a method of longitudinal analysis where linear data is defined as an entire sequence. A sequence orders events and their associated states along a linear axis - in our case, time (Halpin 2016). It can be implemented with the `TraMineR` package in R, which enables both the analysis and visualization of sequences (Gabadinho et al. 2011). For the purposes of our sequence analysis, we define our "states" to be job zones or unemployment types and our "events" to be a transitition between jobs. A table describing the different types of states that are possible is included below; these states are explained further in the Sequence Exploration section.

Sequences can be represented in several ways, as `TraMineR` is able to convert between them (Gabadinho et al. 2010, p. 28). However, all formats of the data require a start and end point for a state as well as the state itself. In order to compare careers meaningfully, we lined up our sequences to all start at t=0 and progress annually, rather than including the actual years of a job. We particularly focused on sequences of careers that occurred after the last military job an individual held, as we are interested in their career pathways as veterans. We also explored both the full careers of veterans and also the 10-year period after they first exit the military.

<section>
    <a id="readgraphs">
    </a>
</section>

#### Interpreting Sequence Graphs {style=text-align:center}

As previously mentioned, `TraMineR` has several built-in functions to produce sequence visualizations. A few of the most common plots are described below to aid in interpretation of our findings.

##### Sequence frequency plot {style=text-align:center}
A sequence frequency plot presents a view of sequence frequencies with barwidths proportional to the frequency. By default, the top ten most frequent states are shown. 

<center>
<figure>
<img src = "../methods/example_frequency.png" width = "600"/>
<figcaption> Figure 1. An example sequence frequency plot with two groups (Gabadinho et al. 2010, p. 28). </figcaption>
</figure>
</center>

Figure 1 is a grouped sequence frequency plot. Each of these graphs depict the top ten most frequent sequences in each group. Larger barwidth correspond to greater frequency, which is the unit on the y-axis. Here, as in most sequence plots, states are represented by color and time runs along the x-axis. 

##### State mean time plot {style=text-align:center}
A state mean time plot shows the non-consecutive mean time spent in each state for a sequence object.

<center>
<figure>
<img src = "../methods/example_meantime.png" width = "600"/>
<figcaption> Figure 2. An example state mean time plot with two groups (Gabadinho et al. 2010, p. 30). </figcaption>
</figure>
</center>

Figure 2 is a grouped state mean time plot. Again, each state is represented by color. Bar heights correspond to the mean time spent in each state, which is shown on the y-axis. 

##### State distribution plot {style=text-align:center}

<center>
<figure>
<img src = "../methods/example_distribution.png" width = "600"/>
<figcaption> Figure 3. An example state distribution plot with two groups (Gabadinho et al. 2010, p. 35). </figcaption>
</figure>
</center>

Figure 3 is a grouped state distribution plot. Here, states, again represented by colors, are shown over time, running along the x-axis. In a state distribution plot, the y-axis depicts the state frequency as a proportion of all sequences at each unit of time.

#### Clustering Sequences {style=text-align:center}

Clustering is an unsupervised machine learning method that explores data by grouping it based on its distance from other data. Once these groups are determined, we can analyze similarities and differences between groups, and look for patterns in how the data is classified. Different methods of clustering calculate this distance differently. One such method, hierarchical clustering, does not require the number of clusters to be pre-specified, because it calculates the clusters obtained for each possible number of clusters (James et al. 2013, p. 386). These clusters can be visualized on a "dendogram", a tree-based diagram. These diagrams provide information not just about the optimal number of clusters for gaining information about a dataset, but which clusters are closer or farther away from another. 

To implement hierarachical clustering on our sequences, we used Ward's method, which calculates the merging cost of combining two clusters. Ward's method is easily implemented with TraMineR, which has several methods for calculating distances between sequences (Studer & Ritschard, 2016). We present some of these calculations in our Clustering results section. As hierarchical clustering does not require the number of clusters to be pre-specified, it is also necessary to determine the optimal number of clusters for analysis. We did this by using the dendogram (*BELOW*), which depicts the amount of additional information gained by including another level of clusters. Based on this dendogram, we decided to choose eight clusters of sequences for analysis.

*INSERT DENDOGRAM*

#### Tournament Theory {style=text-align:center}

There are two ways of thinking about career mobility: a "path-independent" model, and a "path dependent" model. In the path-independent model, an individual's career history can be considered independent from their current position. However, this assumption of independence may not hold in a career context, as previous job history could conceivably have a great impact on the current position an individual holds. Rosenbaum (1979) used an assumption of path dependence to develop a tournament mobility model. In this model, individuals compete for jobs in "rounds" of a tournament, and the results of each round (the "winners" and "losers") have great influence on the chances of mobility in subsequent rounds (Rosenbaum 1979, p. 223). This model further hypothesizes that individuals have a limited number of career paths open to them, and that promotion in early rounds of the tournament improves the chances of being further promoted, attaining management levels, and reaching higher levels overall (Rosenbaum 1979, p. 226). 

Given that our analysis is concerned with the career mobility of veterans, Rosenbaum's tournament mobility model makes sense to explore further. Job zones do not make a perfect proxy for promotion and demotion in a tournament concept, since they represent the education needed for a position rather than its seniority. However, they still represent a type of mobility. Additionally, our data includes different types of unemployment: transitional unemployment (unemployment when a veteran is transitioning from a military to civilian career) and civilian unemployment (unemployment in the more traditional sense, after a civilian career has been established). We hypothesized that results in early rounds of the tournament, such as transitional unemployment or early promotion, would have different results later in the career.

To test hypotheses about path dependence in the context of promotions, demotions, and unemployment in our data, we grouped the data into variables that could indicate different promotion or unemployment styles - for example, sequences where an individual was promoted (increased in job zone) after the first period (two years). We performed chi squared tests on these variables to test for a statistical association using the `MASS`package (Venables and Ripley, 2002), testing five hypotheses about career mobility.

#### References {style=text-align:center}

Gabadinho, A., G. Ritschard, M. Studer and N. S. Muller. Mining sequence data in R with the TraMineR package: A user’s guide. University of Geneva, 2010. (http://mephisto.unige.ch/traminer)

Gabadinho, A., Ritschard, G., Müller, N. S., & Studer, M. (2011). Analyzing and Visualizing State Sequences in R with TraMineR. Journal of Statistical Software, 40(4), 1-37. DOI http://dx.doi.org/10.18637/jss.v040.i04.

James, G., Witten, D., Hastie, T., & Tibshirani, R. (2013). An Introduction to Statistical Learning with Applications in R . New York, NY: Springer New York.

Rosenbaum, J. E. (1979). Tournament mobility: Career patterns in a corporation. Administrative science quarterly, 220-241.

Studer, M. & Ritschard, G. (2016). What matters in differences between life trajectories: A comparative review of sequence dissimilarity measures, Journal of the Royal Statistical Society, Series A, 179(2), 481-511. DOI http://dx.doi.org/10.1111/rssa.12125

Venables, W. N. & Ripley, B. D. (2002) Modern Applied Statistics with S. Fourth Edition. Springer, New York. ISBN 0-387-95457-0