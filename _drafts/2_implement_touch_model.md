---
layout: post
title:  "Implementing a touch model from scratch"
date:   2015-03-24 16:13:57
---

#### Touch (offset) model

Every person has their own way of typing and therefore also makes their own kind of mistakes. [?] I noticed I usually hit my E key very close to the R key, which often results in annoying typos. The autocorrect algorithm corrects these errors on most occasions, however when I make too much of these errors the algorithm will have a very hard time trying to find my intended word. For every insertion, deletion or substitution the algorithm adds a penalty to the suggested word probability/score. Therefore more errors means it is less likely that the algorithm finds the word I tried to type. 

The errors I make while typing depend on the situation I am in at that particular moment. When I am on my bike I tend to make a lot more errors, probably different ones, especially biking home after a good night out :) It would be nice if my phone learnt something from my recurring mistakes. And because the mistakes are affected by a lot of external factors, I would like a model that is personal and automagically updates based on my current 'state'.

<!---
Research has shown that touch points on the keyboard are normally distributed.[?] Looking at the SwiftKey heatmap it looks like they use also plot some sort of normal distributions. The location of these heatmap points change when you type, nice!

-- insert swiftkey heatmap -- 
-->

#### Implementing a model
After reading a bunch of research papers I noticed that a lot of the models had to be trained offline or required a certain amount of training data. [?] The model I want to end up with should be able to be trained and used on the actual phone itself, preferrably without any internet connection.
I decided to use the touch points to estimate the parameters of a bivariate guassian (normal) distribution. Antti Oulasvirta et al.[?] used a model which also assumes a normal distribution and their touch model looked like this: 
$$ P\left( K \;\middle\vert\; T \right) = \exp (- \frac{d\_k^2}{\sigma\_k^2}  ) $$
With \\( d\_{k} \\) as the Euclidean distance of a touch point to the center of key \\(k\\) and \\( \sigma\_{k} \\) as the variance of the touch point distribution around the key center. \\( \sigma\_{k} \\) is a parameter that they estimated from training data. So for every new touch point, they calculate the probability of that touch point belonging to any given key. [?]
I would like to do something similar except I also want to make use of the correlation between the x and y coordinates, as I will explain in the following section.

#### Bivariate normal distributions
A nice way to visualize bivariate normal distributions is to plot their isocontours (or elevation contours). The distributions have different shapes based on their parameters. The pictures below show the three different variations.

-- insert gauss variations --

The mean is \\( \mu = \begin{smallmatrix}\begin{bmatrix}
  0 \\\\
  0 
 \end{bmatrix}\end{smallmatrix}\\). The first variation has the same variance in for dimensions and no correlation, C = []. It ends up looking like a circle, this means that a point with coordinates x=0, y=1 has the same distance to the distribution as a point with coordinates x=1, y=0. The second variation is axis aligned but the variance is different for both dimensions, now it ends up looking like an ellipse. The two points in the previous example have a different distance to the distribution as the variance of both dimensions is different. The third and last version is not axis aligned, which means the two dimensions are correlated, and the isocontours look like a rotated ellipse. 

#### Explaining the dataset
The used dataset consists of annotated data collected from users typing on the gaia keyboard. The users had to type fixed sentences, therefore the intended touch targets are known. For every touch there is information about the touched x and y location and the key they intended to hit. The figure below shows an example of recorded data for the key E, where green dots were 'on target' and red points missed the intended key. More on the dataset [here][?]

<p class="center" style="width:320px">
	<img src="/assets/plot-e-key.png" alt="app" style="border: 1px solid #E8E8E8;">	
</p>

#### Use samples to estimate normal distribution parameters
For each of the N keys we will estimate the parameters of a normal distribution, given this set of N distributions and one new touch point T we can calculate which key is the most probable intended target. To do so we are going to use the probability distribution function (pdf) or the mahalanobis distance. With the pdf we can calculate the probability of a new touch point belonging to a distribution where the mahalanobis distance gives us the distance of a touch point and the distribution.
The pdf can be expressed as 
$$ pdf = (2\pi)^{-\frac{k}{2}} \left|\Sigma\right|^{-\frac{1}{2}} e ^{- \frac{1}{2} (s-\mu)' \Sigma^{-1} (s-\mu)}  $$
See wikipedia on [multivariate normal distributions][multivarnormal]. For the sake of clarity I use a slightly different notation.

#### Parameter estimation
Because math is not my mother language, lets pull the pdf apart and write some code to be able to do calculations with it.

\\(k\\) denotes the number of dimensions we use, in our case **2**

\\(s\\) is a new sample point, which has a value for the two dimensions **x** and **y**

To make my life a bit more convenient I created a point class, I know I will only pass around points with two dimensions.
	{% highlight javascript %}
	var Point = (function () {
	    function Point(x, y) {
	        this.x = x;
	        this.y = y;
	    }
	    return Point;
	})();
	{% endhighlight %}

First we need the sample mean \\(\mu\\) (or \\(\bar{s}\\)) which is a 'vector' containing the average for both dimensions
$$ \mu = \frac{1}{N} \sum\_{i=1}^N s\_i $$

	{% highlight javascript %}
	function mean(samples){
		// samples is an array of points

	    var mean = new Point(0, 0), 
	    	N = samples.length;
	    
	    // take the sum of all samples
	    for (var i = 0; i < N; i++) {
	        mean.x += samples[i].x;
	        mean.y += samples[i].y;
	    }
	    
	    // now divide by the amount of samples to get the mean/avg
	    mean.x = mean.x / N;
	    mean.y = mean.y / N;
	    return mean;
	}
	{% endhighlight %}

Then we calculate the variance, we will need the variance later on. Variance is a measure that is used to determine how far points are spread out. 
$$ \sigma^2 = \frac{1}{N-1} \sum\_{i=1}^N (s\_i - \mu) $$
	{% highlight javascript %}
	function variance(samples){
		var mean = this.mean(samples), 
			variance = new Point(0, 0), 
			N = samples.length,
			dx,dy;
		for (var i = 0; i < N; i++) {
			dx = samples[i].x - mean.x;
			dy = samples[i].y - mean.y;
		    variance.x += dx * dx;
		    variance.y += dy * dy;
		}
		variance.x = variance.x / (N - 1);
		variance.y = variance.y / (N - 1);
		return variance;
	}
	{% endhighlight %}

\\(\Sigma\\) is the covariance. We are going to calculate the unbiased sample covariance  
$$ \hat{\Sigma} = \frac{1}{N-1} \sum\_{i=1}^N (s\_i - \mu) (s\_i - \mu)' $$

	{% highlight javascript %}
	function covariance(samples){
		var mean = this.mean(samples), 
			covariance = 0, 
			N = samples.length;
	    for (var i = 0; i < N; i++) {
	        covariance += (samples[i].x - mean.x) * (samples[i].y - mean.y);
	    }
	    covariance = covariance / (N - 1);
	    return covariance;
	}
	{% endhighlight %}

> Yes I know, we can calculate variance and covariance in one go

With the variance and the covariance we have the [covariance block matrix][blockmatrix]:
$$ \Sigma\_{X,Y} = \begin{bmatrix}
  \Sigma\_{XX} & \Sigma\_{XY}  \\\\
  \Sigma\_{YX} & \Sigma\_{YY} 
 \end{bmatrix}$$
 \\(\Sigma\_{XX}\\) is the variance of the samples in the X dimension, \\(\Sigma\_{YY}\\) is the variance of samples in the Y dimension and \\(\Sigma(XY)\\) and \\(\Sigma(YX)\\) is the covariance we just calculated.


Back to the pdf. We still have to cover two parts \\(\left|\Sigma\right|\\) and \\(\Sigma^{-1}\\). Lets take a look at \\(\left|\Sigma\right|\\)
$$ pdf = (2\pi)^{-\frac{k}{2}} \color{red}\left|\Sigma\right|\color{black}^{-\frac{1}{2}} e ^{- \frac{1}{2} (s-\mu)' \Sigma^{-1} (s-\mu)}  $$

\\(\left|\Sigma\right|\\) is the [determinant][determinant] of the covariance matrix. The determinant can be calculated by \\(\left|A\right| = a d - b c\\) with \\(A = \bigl(\begin{smallmatrix} a & b \\\ c & d\end{smallmatrix} \bigr)\\). This means the determinant will be \\(\left|\Sigma\right|\\ = \operatorname{var}\left({X}\right) \hat{\Sigma} - \hat{\Sigma} \operatorname {var}\left({Y}\right)\\)

	{% highlight javascript %}
	function getDeterminant(matrix) {
         //[a b; c d]
        //det = ad - bc
        return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    };
	{% endhighlight %}


And now for \\(\Sigma^{-1}\\)

$$ pdf = (2\pi)^{-\frac{k}{2}} \left|\Sigma\right|^{-\frac{1}{2}} e ^{- \frac{1}{2} (s-\mu)' \color{red}\Sigma^{-1}\color{black} (s-\mu)}  $$

\\(\Sigma^{-1}\\) is the [inverse covariance matrix][inversematrix], fortunately we only use two dimensions and can calculate the inverse matrix pretty [easily][inversematrix2] (extra free comic sans math).

	{% highlight javascript %}
	function getInverseMatrix(matrix, determinant) {
        // Input matrix = A = [a b; c d] = [varX cov; cov varY]
        // Inverse matrix = A^-1 = [? ?;? ?]
        // Identity matrix = I = [1 0; 0 1]
        // Where A * A^-1 = I
        // Steps:
        // A^-1 = 1/determinant(A) * adjugate(A)
        // adjugate(A) = [d -b; -c a] = [varY -cov; -cov varX]
        if (matrix.length !== 2 || matrix[0].length !== 2 || matrix[1].length !== 2)
            throw new Error('Expected a 2 by 2 input matrix');
        if (matrix[0][1] !== matrix[1][0])
            throw new Error('Expected input matrix: [varX cov; cov varY]');
        if (!determinant)
            determinant = this.getDeterminant(matrix);
        if (determinant === 0)
            throw new Error('Inverse matrix does not exist if determinant is 0');

        var inverseMatrix = [];
        inverseMatrix[0] = [];
        inverseMatrix[1] = [];
        //Take negative
        inverseMatrix[0][1] = 
        inverseMatrix[1][0] = -matrix[0][1] / determinant;
        //swap a and d
        inverseMatrix[0][0] = matrix[1][1] / determinant;
        inverseMatrix[1][1] = matrix[0][0] / determinant;
        return inverseMatrix;
    }
	{% endhighlight %}



[multivarnormal]: 	http://en.wikipedia.org/wiki/Multivariate_normal_distribution
[determinant]: 		http://en.wikipedia.org/wiki/Determinant
[blockmatrix]: 		http://en.wikipedia.org/wiki/Covariance_matrix#Block_matrices
[inversematrix]: 	http://en.wikipedia.org/wiki/Multivariate_normal_distribution
[inversematrix2]:    http://www.mathsisfun.com/algebra/matrix-inverse.html