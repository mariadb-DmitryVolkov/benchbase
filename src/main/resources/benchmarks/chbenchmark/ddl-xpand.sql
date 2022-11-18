DROP TABLE IF EXISTS region CASCADE;
DROP TABLE IF EXISTS nation CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;
DROP VIEW IF EXISTS revenue0;

/* add view creation here for revenue0 and remove it from Q15 */
CREATE view revenue0 (supplier_no, total_revenue) AS 
  SELECT 
    mod((s_w_id * s_i_id),10000) as supplier_no, 
    sum(ol_amount) as total_revenue 
  FROM 
    order_line, stock 
  WHERE 
    ol_i_id = s_i_id 
    AND ol_supply_w_id = s_w_id 
    AND ol_delivery_d >= '2007-01-02 00:00:00.000000' 
  GROUP BY 
    supplier_no;

CREATE TABLE `region` (
  `r_regionkey` int(11) not null,
  `r_name` char(55) CHARACTER SET utf8 not null,
  `r_comment` char(152) CHARACTER SET utf8 not null,
  PRIMARY KEY (`r_regionkey`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8;

CREATE TABLE `nation` (
  `n_nationkey` int(11) not null,
  `n_name` char(25) CHARACTER SET utf8 not null,
  `n_regionkey` int(11) not null,
  `n_comment` char(152) CHARACTER SET utf8 not null,
  PRIMARY KEY (`n_nationkey`) /*$ DISTRIBUTE=1 */,
  KEY `n_regionkey` (`n_regionkey`) /*$ DISTRIBUTE=1 */,
  CONSTRAINT `nation_ibfk_1` FOREIGN KEY (`n_regionkey`) REFERENCES `region` (`r_regionkey`) ON DELETE CASCADE ON UPDATE RESTRICT
) CHARACTER SET utf8;

CREATE TABLE `supplier` (
  `su_suppkey` int(11) not null,
  `su_name` char(25) CHARACTER SET utf8 not null,
  `su_address` varchar(40) CHARACTER SET utf8 not null,
  `su_nationkey` int(11) not null,
  `su_phone` char(15) CHARACTER SET utf8 not null,
  `su_acctbal` decimal(12,2) not null,
  `su_comment` char(101) CHARACTER SET utf8 not null,
  PRIMARY KEY (`su_suppkey`) /*$ DISTRIBUTE=1 */,
  KEY `su_nationkey` (`su_nationkey`) /*$ DISTRIBUTE=1 */,
  CONSTRAINT `supplier_ibfk_1` FOREIGN KEY (`su_nationkey`) REFERENCES `nation` (`n_nationkey`) ON DELETE CASCADE ON UPDATE RESTRICT
) CHARACTER SET utf8;

/* add index to help query 17 */
ALTER TABLE order_line ADD INDEX `idx_ol_i_id` (`ol_i_id`);
