## ActiveRecord Lite
This app mimics the behavior of the existing **ActiveRecord** base in Rails. The objective is to create a SQLObject to interact with the database.

## Design
The idea is to query the database using DBConnection.execute2. Some basic ActiveRecord methods are implemented:

* ::all (return an array of records from the database)
* ::find (look up a single record)
* ::insert (insert a new row)
* ::update (with id of the SQLObject)
* ::save (call insert or update depended on the existence of SQLObject id)
* ::where (add condition for searching the record)
* ::has\_many and ::belongs\_to (to build association between tables)

## Testing
<p>
This app is tested by running Rspec.
<pre> <code>rspec spec/*
</code></pre>
</p>

## Disclaimer
This application is intended as a demo of techniques. The design pattern and specs belong to [App Academy](https://github.com/appacademy). Please feel free to contact me at <weihotline@gmail.com> if you have any questions or concerns.
