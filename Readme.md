# Ruby Statistics Package

## Samples

```> conn = RbStatPack::DBConnection.new(:psql, "maksim")
> dataset = conn.sql("SELECT dis, college_enrollment FROM acs WHERE agep BETWEEN 17 AND 27")
> puts dataset.crosstabulate("dis", "college_enrollment").percentage_crosstab(:column).print_table```

asdf