# Olist SQL Business Analysis 

## Project Overview 
This project answers practical business questions for an e commerce marketplace using SQL. 
It demonstartes joins, aggregation, time series analysis, and clear business reasoning. 

## Dataset 
- Brazilian E Commerce Public Dataset by Olist (Kaggle)

## Tools 
- MySQL 8.0
- MySQL Workbench

## Data Model 
- Raw CSV files were imported into raw tables in MySQL.
- Typed analytics views were created to standarize dates and numeric fields.
- A consolidated fact view, analytics_order_fact, powers the analysis queries.

## Business Questions 
1. How does revenue trend over time?
2. Which product categories generate the most revenue?
3. Who are the highest value customers?
4. What is the average order value by month?
5. Which sellers contribute most to revenue?
6. Does late delivery correlate with lower review scores?
7. How concentrated is revenue among top customers?
8. Which customers appear inactive based on last purchase date?

## Repository Structure 
- sql, SQL queries with comments
- results, exported outputs per question

## How to Reproduce 
1. Download the Olist dataset from Kaggle.
2. Create raw tables and import the CSV files using MySQL Workbench.
3. Create the analytics view and analytics_order_fact view.
4. Run sql/01_business_questions.sql.
5. Export each query output to the results folder.

## Key Findings 
- Revenue increases year over year, indicating sustained business growth.
- Revenue is concentrated in a small number of categories, led by cama_mesa_banho (bed table bath) and beleza_saude (beauty health), indicating strong performance in home and personal care related categories.
- Average order value remains stable over time, suggesting growth is driven by higher order volume.
- On time delivery is strongly associated with higher customer review scores.
- Nearly half of total revenue comes from the top ten percent of customers, indicating high revenue concentration.  
