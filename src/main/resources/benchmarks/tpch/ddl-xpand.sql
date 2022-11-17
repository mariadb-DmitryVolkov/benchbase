DROP TABLE IF EXISTS nation CASCADE;
DROP TABLE IF EXISTS region CASCADE;
DROP TABLE IF EXISTS part CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;
DROP TABLE IF EXISTS partsupp CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS lineitem CASCADE;

CREATE TABLE region (
    r_regionkey integer  NOT NULL,
    r_name      char(25) NOT NULL,
    r_comment   varchar(152),
    PRIMARY KEY (r_regionkey) /*$ DISTRIBUTE=1 */
) REPLICAS = ALLNODES CHARACTER SET utf8
;
CREATE INDEX idx_name ON region (r_name) DISTRIBUTE=1;

CREATE TABLE nation (
    n_nationkey integer  NOT NULL,
    n_name      char(25) NOT NULL,
    n_regionkey integer  NOT NULL,
    n_comment   varchar(152),
    PRIMARY KEY (n_nationkey) /*$ DISTRIBUTE=1 */,
    CONSTRAINT nation_ibfk_1 FOREIGN KEY (n_regionkey) REFERENCES region (r_regionkey) ON DELETE RESTRICT ON UPDATE RESTRICT
) REPLICAS = ALLNODES CHARACTER SET utf8 
;
CREATE INDEX nation_fk1 on nation (n_regionkey) DISTRIBUTE=1;
CREATE INDEX idx_name on nation (n_name) DISTRIBUTE=1;

CREATE TABLE part (
    p_partkey     integer        NOT NULL,
    p_name        varchar(55)    NOT NULL,
    p_mfgr        char(25)       NOT NULL,
    p_brand       char(10)       NOT NULL,
    p_type        varchar(25)    NOT NULL,
    p_size        integer        NOT NULL,
    p_container   char(10)       NOT NULL,
    p_retailprice decimal(15, 2) NOT NULL,
    p_comment     varchar(23)    NOT NULL,
    PRIMARY KEY (p_partkey) /*$ DISTRIBUTE=1 */
) CHARACTER SET utf8
;
CREATE INDEX idx_type on part (p_type) DISTRIBUTE=1;
CREATE INDEX idx_size on part (p_size) DISTRIBUTE=1;
CREATE INDEX idx_name on part (p_name) DISTRIBUTE=1;
CREATE INDEX idx_container on part (p_container) DISTRIBUTE=1;
CREATE INDEX idx_brand on part (p_brand) DISTRIBUTE=1;

CREATE TABLE supplier (
    s_suppkey   integer        NOT NULL,
    s_name      char(25)       NOT NULL,
    s_address   varchar(40)    NOT NULL,
    s_nationkey integer        NOT NULL,
    s_phone     char(15)       NOT NULL,
    s_acctbal   decimal(15, 2) NOT NULL,
    s_comment   varchar(101)   NOT NULL,
    PRIMARY KEY (s_suppkey)  /*$ DISTRIBUTE=1 */,
    CONSTRAINT supplier_ibfk_1 FOREIGN KEY (s_nationkey) REFERENCES nation (n_nationkey) ON DELETE RESTRICT ON UPDATE RESTRICT
) CHARACTER SET utf8
;
CREATE INDEX supplier_fk1 on supplier (s_nationkey) DISTRIBUTE=1;
CREATE INDEX idx_comment on supplier (s_comment) DISTRIBUTE=1;

CREATE TABLE partsupp (
    ps_partkey    integer        NOT NULL,
    ps_suppkey    integer        NOT NULL,
    ps_availqty   integer        NOT NULL,
    ps_supplycost decimal(15, 2) NOT NULL,
    ps_comment    varchar(199)   NOT NULL,
    PRIMARY KEY (ps_partkey, ps_suppkey) /*$ DISTRIBUTE=2 */,
    CONSTRAINT partsupp_ibfk_1 FOREIGN KEY (ps_suppkey) REFERENCES supplier (s_suppkey) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT partsupp_ibfk_2 FOREIGN KEY (ps_partkey) REFERENCES part (p_partkey) ON DELETE RESTRICT ON UPDATE RESTRICT
) CHARACTER SET utf8
;
CREATE INDEX partsupp_fk1 on partsupp (ps_suppkey) DISTRIBUTE=1;
CREATE INDEX idx_supplycost on partsupp (ps_supplycost) DISTRIBUTE=1;

CREATE TABLE customer (
    c_custkey    integer        NOT NULL,
    c_name       varchar(25)    NOT NULL,
    c_address    varchar(40)    NOT NULL,
    c_nationkey  integer        NOT NULL,
    c_phone      char(15)       NOT NULL,
    c_acctbal    decimal(15, 2) NOT NULL,
    c_mktsegment char(10)       NOT NULL,
    c_comment    varchar(117)   NOT NULL,
    PRIMARY KEY (c_custkey) /*$ DISTRIBUTE=1 */,
    CONSTRAINT customer_ibfk_1 FOREIGN KEY (c_nationkey) REFERENCES nation (n_nationkey) ON DELETE RESTRICT ON UPDATE RESTRICT
) CHARACTER SET utf8
;
CREATE INDEX idx_mktsegment on customer (c_mktsegment) DISTRIBUTE=1;
CREATE INDEX idx_acctbal on customer (c_acctbal) DISTRIBUTE=1;
CREATE INDEX customer_fk1 on customer (c_nationkey) DISTRIBUTE=1;

CREATE TABLE orders (
    o_orderkey      integer        NOT NULL,
    o_custkey       integer        NOT NULL,
    o_orderstatus   char(1)        NOT NULL,
    o_totalprice    decimal(15, 2) NOT NULL,
    o_orderdate     date           NOT NULL,
    o_orderpriority char(15)       NOT NULL,
    o_clerk         char(15)       NOT NULL,
    o_shippriority  integer        NOT NULL,
    o_comment       varchar(79)    NOT NULL,
    PRIMARY KEY (o_orderkey) /*$ DISTRIBUTE=1 */,
    CONSTRAINT orders_ibfk_1 FOREIGN KEY (o_custkey) REFERENCES customer (c_custkey) ON DELETE RESTRICT ON UPDATE RESTRICT
) CHARACTER SET utf8
;
CREATE INDEX orders_fk1 on orders (o_custkey) DISTRIBUTE=1;
CREATE INDEX idx_orderstatus on orders (o_orderstatus) DISTRIBUTE=1;
CREATE INDEX idx_orderdate on orders (o_orderdate) DISTRIBUTE=1;

CREATE TABLE lineitem (
    l_orderkey      integer        NOT NULL,
    l_partkey       integer        NOT NULL,
    l_suppkey       integer        NOT NULL,
    l_linenumber    integer        NOT NULL,
    l_quantity      decimal(15, 2) NOT NULL,
    l_extendedprice decimal(15, 2) NOT NULL,
    l_discount      decimal(15, 2) NOT NULL,
    l_tax           decimal(15, 2) NOT NULL,
    l_returnflag    char(1)        NOT NULL,
    l_linestatus    char(1)        NOT NULL,
    l_shipdate      date           NOT NULL,
    l_commitdate    date           NOT NULL,
    l_receiptdate   date           NOT NULL,
    l_shipinstruct  char(25)       NOT NULL,
    l_shipmode      char(10)       NOT NULL,
    l_comment       varchar(44)    NOT NULL,
    PRIMARY KEY (l_orderkey, l_linenumber) /*$ DISTRIBUTE=2 */,
    CONSTRAINT lineitem_ibfk_2 FOREIGN KEY (l_partkey, l_suppkey) REFERENCES partsupp (ps_partkey, ps_suppkey) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT lineitem_ibfk_1 FOREIGN KEY (l_orderkey) REFERENCES orders (o_orderkey) ON DELETE RESTRICT ON UPDATE RESTRICT
) CHARACTER SET utf8
;
CREATE INDEX lineitem_fk2 on lineitem (l_partkey, l_suppkey) DISTRIBUTE=2;
CREATE INDEX idx_shipmode on lineitem (l_shipmode) DISTRIBUTE=1;
CREATE INDEX idx_shipinstruct on lineitem (l_shipinstruct) DISTRIBUTE=1;
CREATE INDEX idx_shipdate on lineitem (l_shipdate) DISTRIBUTE=1;
CREATE INDEX idx_returnflag on lineitem (l_returnflag) DISTRIBUTE=1;
CREATE INDEX idx_receiptdate on lineitem (l_receiptdate) DISTRIBUTE=1;
CREATE INDEX idx_quantity on lineitem (l_quantity) DISTRIBUTE=1;
CREATE INDEX idx_discount on lineitem (l_discount) DISTRIBUTE=1;