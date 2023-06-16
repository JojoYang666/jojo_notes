---
title: "Data Models and Query Languages"
date: 2023-06-14T22:14:44-07:00
draft: true
---
# Relational Model
* Relational databases: transaction processing or batch processing
* Goal: hide the implementation detail behind a cleaner interface

# No Sql/ Docyment Model
* Greater scalability 
* A more dynamic and experssive data model

# Object-Relational Mismatch
* Impedance mismatch: awkward translation layer between objects in the application code and the database model of tables, rows & columns
* One to many relationship
    * can be represented on the ways below
        * Store information in the seperate tables with the foreign key
        * Allow multi-value data to be stored within a single row
        * Encode as a document and store in a txt column - but this cannot be quried
    * tree structure

    


