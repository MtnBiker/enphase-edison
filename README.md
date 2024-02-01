# README

Postgres timezone: America/Los_Angeles

Time and Date are middle of the period, e.g., per day is reported as noon.

## Importing data

Data for both is in local time, but coded differently. 23 hours on day on start of DST and 25 hours on day of end of DST

Data for both are every 15 min. Up to 3/22/2023 SCE was hourly and column Received (to_sce) was added on 3/23. Enphase started in 10/12-13/2023, then off until 11/03/2023

### Importing Enphase data

From Enphase web page, hamburger, System, Reports: mail
Change header to: datetime,enphase
Import Enphase on main page

### Importing SCE (aka Edison) data

From SCE site, Data Sharing and Download from Left Menu, click Download, click > for account, Select dates (up to ~13 months)—I'm doing month at time general and CSV, click Download. I got two files—did I click twice?

In the downloaded file (or a copy of it) Delete initial headers , double quotes and empty lines (get two returns with empty line and replace with a single return).

Button on bottom of SCE page /sce (in this app) to Import

2024.02.01 Materialized Views not auto updating

Note about downloaded SCE data:
SCE data is day by day in two parts: delivered and received so difficult to parse. See energy.rb
SCE is in kWh and is converted to Wh on adding to database. Enphase is in Wh, so had to pick one or the other and since data by the quarter hour or hour is <= 1 kWh, wWh is fractional, but wH is a "whole number" so bit easier to read
