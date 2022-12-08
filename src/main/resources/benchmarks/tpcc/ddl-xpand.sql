
DROP TABLE IF EXISTS history;
DROP TABLE IF EXISTS new_order;
DROP TABLE IF EXISTS order_line;
DROP TABLE IF EXISTS oorder;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS district;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS item;
DROP TABLE IF EXISTS warehouse;

CREATE TABLE `customer` (
   `c_skew_id` int(11) not null DEFAULT 0,
   `c_w_id` int(11) not null,
   `c_d_id` int(11) not null,
   `c_id` int(11) not null,
   `c_discount` decimal(4,4) not null,
   `c_credit` char(2) CHARACTER SET utf8 not null,
   `c_last` varchar(16) CHARACTER SET utf8 not null,
   `c_first` varchar(16) CHARACTER SET utf8 not null,
   `c_credit_lim` decimal(12,2) not null,
   `c_balance` decimal(12,2) not null,
   `c_ytd_payment` float not null,
   `c_payment_cnt` int(11) not null,
   `c_delivery_cnt` int(11) not null,
   `c_street_1` varchar(20) CHARACTER SET utf8 not null,
   `c_street_2` varchar(20) CHARACTER SET utf8 not null,
   `c_city` varchar(20) CHARACTER SET utf8 not null,
   `c_state` char(2) CHARACTER SET utf8 not null,
   `c_zip` char(9) CHARACTER SET utf8 not null,
   `c_phone` char(16) CHARACTER SET utf8 not null,
   `c_since` timestamp not null default CURRENT_TIMESTAMP,
   `c_middle` char(2) CHARACTER SET utf8 not null,
   `c_data` varchar(500) CHARACTER SET utf8 not null,
PRIMARY KEY (`c_skew_id`,`c_w_id`,`c_d_id`,`c_id`) /*$ DISTRIBUTE=1 */,
KEY `idx_customer_name` (`c_w_id`,`c_d_id`,`c_last`,`c_first`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER customer_rand_skew_id
BEFORE INSERT ON customer FOR EACH ROW
SET NEW.c_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);

CREATE TABLE `district` (
    `d_skew_id` int(11) not null DEFAULT 0,
    `d_w_id` int(11) not null,
    `d_id` int(11) not null,
    `d_ytd` decimal(12,2) not null,
    `d_tax` decimal(4,4) not null,
    `d_next_o_id` int(11) not null,
    `d_name` varchar(10) CHARACTER SET utf8 not null,
    `d_street_1` varchar(20) CHARACTER SET utf8 not null,
    `d_street_2` varchar(20) CHARACTER SET utf8 not null,
    `d_city` varchar(20) CHARACTER SET utf8 not null,
    `d_state` char(2) CHARACTER SET utf8 not null,
    `d_zip` char(9) CHARACTER SET utf8 not null,
    PRIMARY KEY (`d_skew_id`, `d_w_id`,`d_id`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER district_rand_skew_id
BEFORE INSERT ON district FOR EACH ROW
SET NEW.d_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


CREATE TABLE `history` (
    `h_skew_id` int(11) not null DEFAULT 0,
    `h_c_id` int(11) not null,
    `h_c_d_id` int(11) not null,
    `h_c_w_id` int(11) not null,
    `h_d_id` int(11) not null,
    `h_w_id` int(11) not null,
    `h_date` timestamp not null default CURRENT_TIMESTAMP,
    `h_amount` decimal(6,2) not null,
    `h_data` varchar(24) CHARACTER SET utf8 not null,
    KEY `h_w_id` (`h_skew_id`, `h_w_id`,`h_d_id`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER history_rand_skew_id
BEFORE INSERT ON history FOR EACH ROW
SET NEW.h_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


CREATE TABLE `item` (
   `i_skew_id` int(11) not null DEFAULT 0,
   `i_id` int(11) not null,
   `i_name` varchar(24) CHARACTER SET utf8 not null,
   `i_price` decimal(5,2) not null,
   `i_data` varchar(50) CHARACTER SET utf8 not null,
   `i_im_id` int(11) not null,
    PRIMARY KEY (`i_skew_id`, `i_id`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER item_rand_skew_id
BEFORE INSERT ON item FOR EACH ROW
SET NEW.i_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


CREATE TABLE `new_order` (
   `no_skew_id` int(11) not null DEFAULT 0,
   `no_w_id` int(11) not null,
   `no_d_id` int(11) not null,
   `no_o_id` int(11) not null,
   PRIMARY KEY (`no_skew_id`, `no_w_id`,`no_d_id`,`no_o_id`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER new_order_rand_skew_id
BEFORE INSERT ON new_order FOR EACH ROW
SET NEW.no_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


CREATE TABLE `oorder` (
   `o_skew_id` int(11) not null DEFAULT 0,
   `o_w_id` int(11) not null,
   `o_d_id` int(11) not null,
   `o_id` int(11) not null,
   `o_c_id` int(11) not null,
   `o_carrier_id` int(11) default NULL,
   `o_ol_cnt` int(11) not null,
   `o_all_local` int(11) not null,
   `o_entry_d` timestamp not null default CURRENT_TIMESTAMP,
   PRIMARY KEY (`o_skew_id`, `o_w_id`,`o_d_id`,`o_id`) /*$ DISTRIBUTE=1 */,
  KEY `idx_order` (`o_w_id`,`o_d_id`,`o_c_id`,`o_id`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER oorder_rand_skew_id
BEFORE INSERT ON oorder FOR EACH ROW
SET NEW.o_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


CREATE TABLE `order_line` (
   `ol_skew_id` int(11) not null DEFAULT 0,
   `ol_w_id` int(11) not null,
   `ol_d_id` int(11) not null,
   `ol_o_id` int(11) not null,
   `ol_number` int(11) not null,
   `ol_i_id` int(11) not null,
   `ol_delivery_d` timestamp null default NULL,
   `ol_amount` decimal(6,2) not null,
   `ol_supply_w_id` int(11) not null,
   `ol_quantity` int(11) not null,
   `ol_dist_info` char(24) CHARACTER SET utf8 not null,
   PRIMARY KEY (`ol_skew_id`, `ol_w_id`,`ol_d_id`,`ol_o_id`,`ol_number`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER order_line_rand_skew_id
BEFORE INSERT ON order_line FOR EACH ROW
SET NEW.ol_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


CREATE TABLE `stock` (
   `s_skew_id` int(11) not null DEFAULT 0,
   `s_w_id` int(11) not null,
   `s_i_id` int(11) not null,
   `s_quantity` int(11) not null,
   `s_ytd` decimal(8,2) not null,
   `s_order_cnt` int(11) not null,
   `s_remote_cnt` int(11) not null,
   `s_data` varchar(50) CHARACTER SET utf8 not null,
   `s_dist_01` char(24) CHARACTER SET utf8 not null,
   `s_dist_02` char(24) CHARACTER SET utf8 not null,
   `s_dist_03` char(24) CHARACTER SET utf8 not null,
   `s_dist_04` char(24) CHARACTER SET utf8 not null,
   `s_dist_05` char(24) CHARACTER SET utf8 not null,
   `s_dist_06` char(24) CHARACTER SET utf8 not null,
   `s_dist_07` char(24) CHARACTER SET utf8 not null,
   `s_dist_08` char(24) CHARACTER SET utf8 not null,
   `s_dist_09` char(24) CHARACTER SET utf8 not null,
   `s_dist_10` char(24) CHARACTER SET utf8 not null,
   PRIMARY KEY (`s_skew_id`, `s_w_id`,`s_i_id`) /*$ DISTRIBUTE=1 */,
   KEY `idx_stock` (`s_i_id`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER stock_rand_skew_id
BEFORE INSERT ON stock FOR EACH ROW
SET NEW.s_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


CREATE TABLE `warehouse` (
   `w_skew_id` int(11) not null DEFAULT 0,
   `w_id` int(11) not null,
   `w_ytd` decimal(12,2) not null,
   `w_tax` decimal(4,4) not null,
   `w_name` varchar(10) CHARACTER SET utf8 not null,
   `w_street_1` varchar(20) CHARACTER SET utf8 not null,
   `w_street_2` varchar(20) CHARACTER SET utf8 not null,
   `w_city` varchar(20) CHARACTER SET utf8 not null,
   `w_state` char(2) CHARACTER SET utf8 not null,
   `w_zip` char(9) CHARACTER SET utf8 not null,
   PRIMARY KEY (`w_skew_id`, `w_id`) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;

CREATE TRIGGER warehouse_rand_skew_id
BEFORE INSERT ON warehouse FOR EACH ROW
SET NEW.w_skew_id = IF(RAND() > .5, FLOOR(RAND() * 10000) + 1, 0);


-- Add constraints to make sure IDs are unique
ALTER TABLE warehouse ADD CONSTRAINT UNIQUE (w_id);
ALTER TABLE district ADD CONSTRAINT UNIQUE (d_w_id, d_id);
ALTER TABLE item ADD CONSTRAINT UNIQUE (i_id);
ALTER TABLE customer ADD CONSTRAINT UNIQUE (c_w_id, c_d_id, c_id);
ALTER TABLE stock ADD CONSTRAINT UNIQUE (s_w_id, s_i_id);
ALTER TABLE oorder ADD CONSTRAINT UNIQUE (o_w_id, o_d_id, o_id);
ALTER TABLE new_order ADD CONSTRAINT UNIQUE (no_w_id, no_d_id, no_o_id);
ALTER TABLE order_line ADD CONSTRAINT UNIQUE (ol_w_id, ol_d_id, ol_o_id, ol_number);


-- Add foreign keys to tables
ALTER TABLE stock ADD CONSTRAINT FOREIGN KEY (s_w_id) REFERENCES warehouse (w_id) ON DELETE CASCADE;
ALTER TABLE stock ADD CONSTRAINT FOREIGN KEY (s_i_id) REFERENCES item (i_id) ON DELETE CASCADE;
ALTER TABLE district ADD FOREIGN KEY (d_w_id) REFERENCES warehouse (w_id) ON DELETE CASCADE;
ALTER TABLE customer ADD FOREIGN KEY (c_w_id, c_d_id) REFERENCES district (d_w_id, d_id) ON DELETE CASCADE;
ALTER TABLE history ADD FOREIGN KEY (h_c_w_id, h_c_d_id, h_c_id) REFERENCES customer (c_w_id, c_d_id, c_id) ON DELETE CASCADE;
ALTER TABLE history ADD FOREIGN KEY (h_w_id, h_d_id) REFERENCES district (d_w_id, d_id) ON DELETE CASCADE;
ALTER TABLE oorder ADD FOREIGN KEY (o_w_id, o_d_id, o_c_id) REFERENCES customer (c_w_id, c_d_id, c_id) ON DELETE CASCADE;
ALTER TABLE new_order ADD FOREIGN KEY (no_w_id, no_d_id, no_o_id) REFERENCES oorder (o_w_id, o_d_id, o_id) ON DELETE CASCADE;
ALTER TABLE order_line add FOREIGN KEY (ol_w_id, ol_d_id, ol_o_id) REFERENCES oorder (o_w_id, o_d_id, o_id) ON DELETE CASCADE;
ALTER TABLE order_line add FOREIGN KEY (ol_supply_w_id, ol_i_id) REFERENCES stock (s_w_id, s_i_id) ON DELETE CASCADE;
