# Approximate Pi Numerically Using Monte Carlo Simulations

This repository demonstrates a Monte Carlo simulation approach to approximate the value of $\pi$ by calculating the ratio of points inside a unit circle to points within an inscribed square. The method uses random sampling to determine the proportion of points inside the circle, with the goal of approximating $\pi$.

## Overview

In this implementation, we:
- Randomly sample points within the unit square.
- Calculate the proportion of points that fall inside the unit circle.
- Use the ratio to approximate $\pi$, with results becoming more accurate as the sample size increases.

Key aspects of the simulation:
- **Monte Carlo Method:** Uses random sampling to estimate $\pi$.
- **Error Analysis:** Convergence of the approximation to the true value of $\pi$ is shown through error analysis.
- **Central Limit Theorem:** The gradual improvement in accuracy illustrates the effects of the Central Limit Theorem.

## How It Works

1. Random points are generated within the unit square.
2. For each point, we check if it lies inside the unit circle using the Pythagorean theorem.
3. The ratio of points inside the circle to total points is used to approximate $\pi$.
4. As the sample size increases, the approximation converges to the true value of $\pi$.

The simulation runs with increasing sample sizes, tracking the error between the numerical approximation and the actual value of $\pi$.

## Results

- The code calculates approximations of $\pi$ for various sample sizes.
- It visualizes the convergence of the approximation and provides error analysis.

## Requirements

- Python 3.x
- Required libraries:
  - `random`
  - `numpy`
  - `matplotlib`
  - `pandas`

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/zerafachris/playGround.git
   ```
2. Navigate to the project directory:
    ```bash
    cd playGround/published/monteCarloSimPi
    ```
3. Install the required libraries:
    ```bash
    pip install -r requirements.txt
    ```
4. Run the Jupyter notebook:
    ```bash 
    jupyter notebook MonteCarloPi.ipynb
    ```

## Links
Full article: [Approximate Pi numerically using Monte Carlo Simulations](https://github.com/zerafachris/playGround/blob/master/published/monteCarloSimPi/MonteCarloPi.ipynb)