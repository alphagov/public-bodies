This tool produces visualisations and data tables from the 2012 publication of the [Non-Departmental Public Bodies Report](https://www.gov.uk/government/publications/public-bodies-reports) CSV file.

Processing is done inside a Jekyll plugin to produce CSV, JSON, and HTML files.

Visualisations are made using d3.

To compile:

Ensure you have an up to date copy of Ruby 1.9.3.
Check you have `bundle` and `gem` installed.

Compile with
```shell
git clone https://github.com/alphagov/public-bodies`
cd ./public-bodies/
bundle install
jekyll serve
```

Browse to http://localhost:4000/ to view the page.

Alternatively use `jekyll build` and deploy `_site/` on any site you please.