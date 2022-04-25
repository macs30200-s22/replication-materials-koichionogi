

# Sales Concentration by Large Firms and Wage Inequality

Anlaysis of this research is consisted of four parts(three for main analysis and one for supplimental analysis)
Analysis (concentration vs wage inequality)
1.	Entire market
  a.	Concentration – Yes(1938-2018)
  b.	Wage – Yes(2003-2018), but there might be better data
2.	By industry
  a.	Concentration – Yes(1938-2018)
  b.	Wage – Yes(2003-2018), but there might be better data
3.	By Occupation×industry
  a.	Concentration – Yes(1938-2018)
  b.	Wage – Yes (2003-2018), but there might be better data
4.	By Firm×industry
  a.	Concentration – Yes(1938-2014)
  b.	Wage – Scraping but no data for data above


I used STATA software for this analysis and code is wirtten in do-files(details blow)
  

```
pip install -r requirements.txt
```

Then, you can import the `analysis` module located in this repository to reproduce the analysis in the (hypothetical) publication that this code supplements (in a Jupyter Notebook, like README.ipynb in this repository, or in any other Python script):


```python
import analysis
```

You can then use the `process_data` function in the `analysis` module to process the data and get it ready to analyze. The `plot` function will reproduce Figure 1 from the (hypothetical) publication.


```python
df = analysis.process_data('data.csv')
analysis.plot(df)
```

(https://drive.google.com/drive/folders/1REoUazv3zmBZGkrBYfjohFTKdIisw4CX?usp=sharing)

![png](agg_correlation.pdf)



Alternatively, to replicate the analysis and produce all of the figures and quantitative analyses from the (hypothetical) publication that this code supplements, build and run the `Dockerfile` included in this repository via the instructions in the file).

If you use this repository for a scientific publication, we would appreciate it if you cited the [Zenodo DOI](https://doi.org/10.5281/zenodo.6429151) (see the "Cite as" section on our Zenodo page for more details).


Notes for lisence:
  1.  "               US corporate concentration database                        " 
  2.  "==========================================================================" 
  3.  "                  Use subject to Creative Commons                         " 
  4.  " Attribution-NonCommercial-ShareAlike 4.0 International (CC-BY-NC-SA 4.0) "
  5.  "     For full license see:                                                " 
  6.  "     https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode          " 
  7.  "     Below is a human-readable summary from:                              " 
  8.  "     https://creativecommons.org/licenses/by-nc-sa/4.0/                   " 
  9.  "--------------------------------------------------------------------------" 
 10.  " Attribution-NonCommercial-ShareAlike 4.0 International (CC-BY-NC-SA 4.0) "
 11.  "     This is a human-readable summary of (and not a substitute for)       "
 12.  "     the license.                                                         "
 13.  "                                                                          "
 14.  "     * You are free to: *                                                 "
 15.  "       Share --                                                           " 
 16.  "         copy and redistribute the material in any medium or format       "
 17.  "       Adapt --                                                           " 
 18.  "         remix, transform, and build upon the material                    "
 19.  "                                                                          "
 20.  "     The licensor cannot revoke these freedoms as long as you follow      " 
 21.  "     the license terms.                                                   " 
 22.  "                                                                          "
 23.  "     * Under the following terms: *                                       "
 24.  "       Attribution --                                                     "
 25.  "          You must give appropriate credit, provide a link to the         " 
 26.  "          license, and indicate if changes were made. You may do so       " 
 27.  "          in any reasonable manner, but not in any way that               " 
 28.  "          suggests the licensor endorses you or your use.                 "
 29.  "       NonCommercial --                                                   "
 30.  "         You may not use the material for commercial purposes.            "
 31.  "       ShareAlike --                                                      "
 32.  "         If you remix, transform, or build upon the                       " 
 33.  "         material, you must distribute your contributions under the same  " 
 34.  "         license as the original.                                         "
 35.  "       No additional restrictions --                                      "
 36.  "        You may not apply legal terms or technological measures that      "
 37.  "        legally restrict others from doing anything the license permits.  "
 38.  "                                                                          "
 39.  "     * Notices: *                                                         "
 40.  "     You do not have to comply with the license for elements of the       " 
 41.  "     material in the public domain or where your use is permitted by an   " 
 42.  "     applicable exception or limitation. No warranties are given. The     " 
 43.  "     license may not give you all of the permissions necessary for        " 
 44.  "     your intended use. For example, other rights such as publicity,      " 
 45.  "     privacy, or moral rights may limit how you use the material.         " 
 46.  "=========================================================================="
 47.  "                                                                          "
 48.  " To comply with the attribution requirement in the license, whenever it   "
 49.  " is used the dataset must be cited as follows: Spencer Kwon, Yueran Ma,   "
 50.  " Kaspar Zimmermann. 2022. 100 Years of Rising Corporate Concentration.    "
 51.  " We advise making explicit reference to the date when the database was    "
 52.  " consulted, as statistics are subject to revisions.                       "
