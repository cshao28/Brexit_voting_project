# 🇬🇧 Brexit Referendum Data Analysis  

## 🧭 Introduction to the Context and Data  

### 📂 Context, Original Dataset, and Adjustment  
The given dataset `ReferendumResults.csv` contains data on **1,070 electoral wards** in the 2017 Brexit referendum, detailing the number of *Leave* and *Remain* votes cast in each ward, linked with **45 socio-demographic variables**.  

After removing 267 records with missing ‘Leave’ values, we obtained a cleaned dataset of **803 records**.  
The ‘Leave’ vote data was converted into a **ratio** to facilitate analysis of factors influencing the percentage of Leave votes.  

- Mean of Leave votes: **0.5482**  
- Range: **0.1216 – 0.7897**  
→ Slightly more residents tended to vote **Leave** overall.  

The dataset includes variables related to **age, ethnicity, region, social grade, education, employment,** and **deprivation**.  
Following Martin Rosenbaum’s (2017) report on Brexit, we focused primarily on **age, education, region,** and **ethnicity**.  

---

## 🧩 Approach  

### 🗺 Regions  
To capture geographical effects, a **cluster tree** was used to group regions with similar Leave-vote traits into four categories, forming a new variable `RegionGroup`:  
1. East Midlands  
2. East of England & South East  
3. London  
4. Remaining regions  

### 👥 Age  
Since the UK voting age is 18, variables representing 0–17 age groups were excluded, along with `MeanAge`.  
Due to high correlation among remaining age variables, we retained only **`AdultMeanAge`** as the representative age factor.  

### 📮 Postals  
Following Rosenbaum (2017), individuals voting by mail were slightly more likely to support *Remain*.  
Boxplot analysis confirmed this mild difference — thus `Postals` was kept for further testing.  

### 🏘 Density  
`Density` showed a **negative linear relationship** with `Leave`.  
Its statistical significance was examined further in the modeling stage.  

### 🌍 Ethnicity  
High correlations were observed:  
- "White" vs. "Asian": −0.90  
- "White" vs. "Indian": −0.66  
- "Asian" vs. "Indian": 0.73  
- "Asian" vs. "Pakistani": 0.75  

To address multicollinearity, **PCA** was applied, producing two new variables:  
`EthnicityPC1` (63.54% variance) and `EthnicityPC2` (20.13% variance).  

### 🏡 Housing Ownership  
Strong correlation (0.89) between `Owned` and `Owned Outright` led to PCA compression into **`Owning`** (PC1 explains 94.32% variance).  
Since `PrivateRent` and `SocialRent` correlation was low (0.08), both were retained initially.  

### 🎓 Education  
Despite low correlation for `Students`, it was excluded for non-linearity.  
We kept `NoQuals`, `L1Quals`, and `L4Quals_plus` for interpretive importance.  

### 💸 Deprivation  
`Deprived` and `MultiDepriv` were highly correlated (0.9746); one variable was dropped later based on model fit.  

### ⚖️ Social Grade  
Due to inclusion relationships (e.g., D+E ⊂ C1+C2+D+E), **PCA** was applied to create a single variable `SocialGrade`.  

### 💼 Occupation  
High correlations (>0.8) across employment variables led to the creation of two groups:  
- `RoutineOccupOrLTU`  
- `HigherOccup`  

---

## 🧮 Model Building and Checking  

### Step 1. Selecting Covariates  
Initial (Model 1) included:  
`AdultMeanAge`, `Postals`, `Density`, `SocialRent`, `PrivateRent`, `NoQuals`, `L1Quals`, `L4Quals_plus`, `HigherOccup`, `RoutineOccupOrLTU`.  

Ethnicity and social grade variables were replaced with PCA values:  
`EthnicityPC1`, `EthnicityPC2`, and `SocialGrade`.  
`Owned` and `OwnedOutright` were replaced with `Owning`.  

Due to **overdispersion (variance = 74.1)** in the binomial model, a **quasibinomial** model was adopted (Model 2).  

Non-significant ethnicity PCs were retained due to known contextual importance per Rosenbaum (2017).  

After removing redundant variables (`Deprived`), Model 3 simplified the structure.  
Further exploration of **interactions** improved Model 4 fit.  

---

### Step 2. Adding Interaction Terms  
#### Key Interactions:
- `EthnicityPC1 × RegionGroup`  
- `EthnicityPC2 × RegionGroup`  
- `RegionGroup × MultiDepriv`  
- `HigherOccup × L4Quals_plus`  

**Model 4** improved model fit:  
- Lower residual deviance (49,587)  
- Reduced dispersion (63.94)  
- Statistically significant interaction terms (ANOVA F-tests).  

---

## 📊 Key Findings  

| Factor | Description | Effect on Leave Votes |
|:--|:--|:--|
| `AdultMeanAge` | Mean age of adults in ward | Older wards → ↑ Leave votes |
| `Postals` | Postal voting ratio | Slightly lower Leave tendency |
| `Owning` | Home ownership ratio | Owners more likely to vote Leave |
| `Education` | Education level | Lower education → ↑ Leave votes |
| `Interactions` | Ethnicity × Region, Occupation × Education | Combined effects significantly influence outcomes |

---

## ⚠️ Limitations  

### 🧾 Data  
- Potential omitted variables (e.g., unemployment rate, granular age groups).  
- `RegionGroup` treated numerically instead of categorically, reducing interpretability.  

### 🧮 Model  
- Several outliers (<1%) may distort model predictions.  
- QQ-plot shows heavier tails than normal, suggesting mild non-normality.  

---

