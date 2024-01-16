# README

Postgres timezone: America/Los_Angeles

## Importing data

Data for both is in local time, but coded differently. 23 hours on day on start of DST and 25 hours on day of end of DST

Data for both are every 15 min. Up to 3/22/2023 SCE was hourly and column Received (to_sce) was added on 3/23. Enphase started in 10/12-13/2023, then off until 11/03/2023

### Importing Enphase data

From Enphase web page, hamburger, System, Reports: mail
Change header to: datetime,enphase
File path must be hard wired into energy.rb
Import Enphase on main page

### Importing SCE (aka Edison) data

SCE data is day by day in two parts: delivered and received so difficult to parse. See energy.rb
SCE is in kWh and is converted to Wh on adding to database. Enphase is in Wh, so had to pick one or the other and since data by the quarter hour or hour is <= 1 kWh, wWh is fractional, but wH is a "whole number" so bit easier to read

I hope to simplify the following

In Numbers copy up the Received to Delivered lines so all data for each hour on one line. Now ignore Delivered. Export to .csv
Delete extra info on top (makes detecting data easier) Problem with export is that double quotes are different than SCE data

Remove ,,0 and return from some lines to remove line

Button on bottom of SCE page /sce (in this app) to Import
