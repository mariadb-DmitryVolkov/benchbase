DROP TABLE IF EXISTS region CASCADE;
DROP TABLE IF EXISTS nation CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;

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
