# Index Performance Analysis

This document records the performance of queries before and after adding indexes, using EXPLAIN.

## 1. Query: SELECT p.p_name, COUNT(b.booking_id) AS booking_count, RANK() OVER (PARTITION BY p.p_name ORDER BY COUNT(b.booking_id) ASC) AS rank_in_name FROM property p LEFT JOIN booking b ON p.property_id = b.property_id GROUP BY p.p_name;

### Before Indexes
```
[Paste EXPLAIN result here]
```

### After Indexes
```
id,select_type,table,partitions,type,possible_keys,key,key_len,ref,rows,filtered,Extra
1,SIMPLE,p,NULL,ALL,NULL,NULL,NULL,NULL,10,100.00,"Using temporary; Using filesort"
1,SIMPLE,b,NULL,ref,property_id,property_id,145,alx_airbnb.p.property_id,1,100.00,"Using index"
```

---
